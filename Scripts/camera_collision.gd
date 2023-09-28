extends Camera3D

@onready var ray = $"../CameraRay"

var distance = 4.6

func _ready():
	ray.target_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if ray.is_colliding():
		global_position = ray.get_collision_point()
	else:
		position = Vector3(0.0, 0.0, distance)
