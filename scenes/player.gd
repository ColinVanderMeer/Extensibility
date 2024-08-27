extends CharacterBody3D

@export var  SPEED = 6.0
var JUMP_VELOCITY = 5
@export var sensivity = 0.1
var fov = false
var lerp_speed= 1

enum SIZE { Small, Normal, Big }
@export var playerSize: SIZE = SIZE.Normal

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


@onready var _raycast := $CameraPivot/Camera3D/RayCast3D
@onready var _holdPos := $CameraPivot/Camera3D/HoldPos
var picked_object
var pullPower = 4.5


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _input(event):
	if event is InputEventMouseMotion:
		$CameraPivot.rotation_degrees.x -= event.relative.y * sensivity
		$CameraPivot.rotation_degrees.x = clamp($CameraPivot.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * sensivity

	if Input.is_action_just_pressed("interact"):
		match playerSize:
			SIZE.Small:
				pass
			SIZE.Normal:	
				if picked_object == null:
					pick_up_object()
				else:
					picked_object = null
			SIZE.Big:
				pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	match playerSize:
		SIZE.Small:
			SPEED = 3.0
			JUMP_VELOCITY = 3
			self.scale = Vector3(0.3, 0.3, 0.3)
		SIZE.Normal:
			SPEED = 6.0
			JUMP_VELOCITY = 5
			self.scale = Vector3(1, 1, 1)
		SIZE.Big:
			SPEED = 15.0
			JUMP_VELOCITY = 8
			self.scale = Vector3(3, 3, 3)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = _holdPos.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pullPower)

func pick_up_object():
	var collider = _raycast.get_collider()
	print(collider)
	if collider != null and collider is RigidBody3D:
		picked_object = collider
