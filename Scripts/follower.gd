extends Node3D

var leader = null
var player
@onready var ray := $RayCast3D
@onready var graphics := $Graphics

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vertical_velocity := 0.0
var random_offset := randf_range(0.0, 2 * PI)

func _physics_process(delta):
	var target_pos = Vector3(leader.global_position.x, position.y, leader.global_position.z)
	position = position.move_toward(target_pos, 5.0 * delta)
	target_pos = ray.get_collision_point() + 0.25 * Vector3.UP
	if target_pos.y < position.y:
		vertical_velocity -= gravity * delta
		position.y += vertical_velocity * delta
		if target_pos.y > position.y:
			position.y = target_pos.y
			vertical_velocity = -1.0
	elif abs(position.y - target_pos.y) < 0.01:
		position.y = target_pos.y
		vertical_velocity = -1.0
	elif target_pos.y > position.y:
		vertical_velocity = max(10.0, 10.0 * (target_pos.y - position.y))
		position.y += vertical_velocity * delta
		vertical_velocity = -1.0
		if target_pos.y < position.y:
			position.y = target_pos.y
	else:
		print("target position is somehow not in 3D space")

func _process(delta):
	if player.get_position_delta().length() > 0.0:
		graphics.position.y = 0.05 * sin(20.0 * player.timer + random_offset)
	else:
		graphics.position.y = 0.0
	basis = player.graphics.basis

func set_leader(target_leader: Node3D):
	leader = target_leader
