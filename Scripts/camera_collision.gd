extends Camera3D

const HOOKE := 1.0
const CHARACTER_MAX_DISTANCE := 0.3

@onready var player := $"../../.."
@onready var ray := $"../CameraRay"
@onready var target := $"../CameraPosTarget"
@onready var yaw_pivot := $"../.."

var distance := 4.6

func _ready():
	ray.target_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pivot_lateral_position := Vector2(yaw_pivot.position.x, yaw_pivot.position.z)
	
	if ray.is_colliding():
		global_position = ray.get_collision_point()
	else:
		global_position = global_position + (HOOKE * delta * (target.global_position - global_position))
	
	if pivot_lateral_position.length() > CHARACTER_MAX_DISTANCE:
		pivot_lateral_position = pivot_lateral_position + (5.0 * HOOKE * delta * (CHARACTER_MAX_DISTANCE * pivot_lateral_position.normalized() - pivot_lateral_position))
		yaw_pivot.position = Vector3(pivot_lateral_position.x, yaw_pivot.position.y, pivot_lateral_position.y)
	yaw_pivot.position.y = yaw_pivot.position.y + (3.0 * HOOKE * delta * (0.8 - yaw_pivot.position.y))

func _physics_process(_delta):
	yaw_pivot.position = yaw_pivot.position - player.get_position_delta()
