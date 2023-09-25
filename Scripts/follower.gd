extends Node3D

var leader = null

func _physics_process(delta):
	if leader is Node3D:
		var target_pos = leader.global_position - (leader.global_position - position).normalized()
		position = position.move_toward(target_pos, 5.0 * delta)

func set_leader(target_leader: Node3D):
	leader = target_leader
