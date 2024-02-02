extends CharacterBody3D

var speed = 5.0 * 1.0 #multiplying speed for testing
const ACCEL = 25.0
const DECEL = 25.0
const JUMP_VELOCITY = 4.5

var mouse_sensitivity := 0.001
var mouse_last_position := Vector2.ZERO
var yaw_input := 0.0
var pitch_input := 0.0
var can_attack := false
var can_step := false
var can_anything := true
@export var herd_size := 1

@onready var yaw := $YawPivot
@onready var pitch := $YawPivot/PitchPivot
@onready var graphics := $Graphics
@onready var camera := $YawPivot/PitchPivot/Camera3D
@onready var camera_ray := $YawPivot/PitchPivot/CameraRay
@onready var timer_node := $Timer
@onready var grass_step := $GrassStep
@onready var audio_timer := $GrassStep/WalkTimer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var timer := 0.0

signal throw_follower(amount: int, destination: Vector3)

func _ready():
	timer_node.timeout.connect(on_timer_timeout)
	audio_timer.timeout.connect(on_audio_timeout)

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
		velocity.x = move_toward(velocity.x, speed * direction.x, ACCEL * delta)
		velocity.z = move_toward(velocity.z, speed * direction.z, ACCEL * delta)
		graphics.look_at(position + (velocity * Vector3(1.0, 0.0, 1.0)))
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL * delta)
		velocity.z = move_toward(velocity.z, 0, DECEL * delta)
	
	if can_anything:
		move_and_slide()
	
	if global_position.y < -50.0:
		global_position = Vector3(0.0, 100.0, 0.0)

func _process(delta):
	timer += delta
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		mouse_last_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_pressed("focus_camera"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if Input.is_action_just_released("focus_camera"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_viewport().warp_mouse(mouse_last_position)
	
	if Input.is_action_pressed("attack") and can_attack and can_anything:
		attack()
		can_attack = false
		timer_node.start()
	
	yaw.rotate_y(yaw_input)
	pitch.rotate_x(pitch_input)
	pitch.rotation.x = clamp(pitch.rotation.x, -1.5, 1.5)
	yaw_input = 0.0
	pitch_input = 0.0
	
	if get_position_delta().length() > 0.01 and can_anything:
		if can_step:
			grass_step.set_pitch_scale(randf_range(0.8, 1.2))
			grass_step.play()
			can_step = false
			audio_timer.start()
		graphics.position.y = 0.05 * sin(20.0 * timer)
	else:
		graphics.position.y = 0.0

func _unhandled_input(event):
		if event is InputEventMouseMotion:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				yaw_input = -event.relative.x * mouse_sensitivity
				pitch_input = -event.relative.y * mouse_sensitivity

func change_camera_distance(distance):
	camera.distance = distance
	camera_ray.target_position.z = distance

func attack():
	var intersection = raycast_from_mouse(get_viewport().get_mouse_position(), 1)
	
	if intersection:
		if (intersection.position - global_position).length() < 20.0:
			throw_follower.emit(1, intersection.position)

# Thanks to MagickPanda on the Godot Forums at
# https://godotforums.org/d/33479-godot-4-raycasting-to-get-mouse-position-in-3d/2
# for this implementation of ray casting!
func raycast_from_mouse(m_pos, ray_collision_mask):
	var ray_start = camera.project_ray_origin(m_pos)
	var ray_end = ray_start + camera.project_ray_normal(m_pos) * 1000.0
	var world3d : World3D = get_world_3d()
	var space_state = world3d.direct_space_state
	
	if space_state == null:
		return
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, ray_collision_mask)
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)

func on_timer_timeout():
	can_attack = true

func on_audio_timeout():
	can_step = true
