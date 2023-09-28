extends CharacterBody3D

const SPEED = 5.0
const ACCEL = 25.0
const DECEL = 25.0
const JUMP_VELOCITY = 4.5

var mouse_sensitivity := 0.001
var yaw_input := 0.0
var pitch_input := 0.0
@export var herd_size := 1

@onready var yaw := $YawPivot
@onready var pitch := $YawPivot/PitchPivot
@onready var graphics := $Graphics
@onready var camera := $YawPivot/PitchPivot/Camera3D
@onready var camera_ray := $YawPivot/PitchPivot/CameraRay

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var timer := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (yaw.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0.0
	if direction:
		velocity.x = move_toward(velocity.x, SPEED * direction.x, ACCEL * delta)
		velocity.z = move_toward(velocity.z, SPEED * direction.z, ACCEL * delta)
		graphics.look_at(position + (velocity * Vector3(1.0, 0.0, 1.0)))
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL * delta)
		velocity.z = move_toward(velocity.z, 0, DECEL * delta)

	move_and_slide()

func _process(delta):
	timer += delta
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	yaw.rotate_y(yaw_input)
	pitch.rotate_x(pitch_input)
	pitch.rotation.x = clamp(pitch.rotation.x, -1.5, 1.5)
	yaw_input = 0.0
	pitch_input = 0.0
	
	if get_position_delta().length() > 0.0:
		graphics.position.y = 0.05 * sin(20.0 * timer)
	else:
		graphics.position.y = 0.0

func _unhandled_input(event):
		if event is InputEventMouseMotion:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				yaw_input = -event.relative.x * mouse_sensitivity
				pitch_input = -event.relative.y * mouse_sensitivity
				
		if event is InputEventMouseButton:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func change_camera_distance(distance):
	camera.distance = distance
	camera_ray.target_position.z = distance
	pass
