extends Node3D

var follower_scene = preload("res://Scenes/follower.tscn")
var follower_instances = []
var follower_targets = []

@onready var objective = $Objective1
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	objective.spawn_follower.connect(on_spawn_follower)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_spawn_follower(amount):
	var _use_amount = amount/2
	follower_instances.append(follower_scene.instantiate())
	follower_targets.append(Node3D.new())
	follower_targets[-1].position = Vector3.FORWARD
	player.add_child(follower_targets[-1])
	add_child(follower_instances[-1])
	follower_instances[-1].set_leader(player)
	print(follower_instances.size())
