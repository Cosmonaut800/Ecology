extends Node3D

var leader = null
var player
@onready var ray := $RayCast3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vertical_velocity := 0.0

func _physics_process(delta):
	var target_pos = leader.global_position
	position = position.move_toward(target_pos, 5.0 * delta)
	target_pos = ray.get_collision_point() + 0.25 * Vector3.UP
	if (position - target_pos).length() > 0.01 and target_pos.y < position.y:
		vertical_velocity -= gravity * delta
		position.y += vertical_velocity * delta
		if position.y < target_pos.y: position.y = target_pos.y
	else:
		vertical_velocity = min(2.0, 0.2 * (target_pos.y - position.y))
		position.y += vertical_velocity
		if (position.y > target_pos.y): position.y = target_pos.y

func _process(_delta):
	basis = player.basis

func set_leader(target_leader: Node3D):
	leader = target_leader
