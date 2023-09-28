extends Node3D

const GOLDEN = 0.618033 # Golden Ratio

var follower_scene = preload("res://Scenes/follower.tscn")
var follower_instances = []
var follower_targets = []

@onready var objective = $Objective1
@onready var player = $Player
@onready var player_graphics = $Player/Graphics
@onready var ground_paint_controller = $GroundPaintController

# Called when the node enters the scene tree for the first time.
func _ready():
	objective.spawn_follower.connect(on_spawn_follower)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_spawn_follower(amount, spawn_position):
	for i in amount:
		follower_instances.append(follower_scene.instantiate())
		follower_instances[-1].position = spawn_position
		follower_instances[-1].player = player_graphics
		follower_targets.append(Node3D.new())
		follower_targets[-1].position = find_spiral_position(follower_instances.size())
		player.add_child(follower_targets[-1])
		add_child(follower_instances[-1])
		follower_instances[-1].set_leader(follower_targets[-1])
		player.herd_size += 1
	
	ground_paint_controller.update_brush_size(follower_targets[-1].position.length())

func find_spiral_position(index: int) -> Vector3:
	var arc_length = 0.612
	var radius = sqrt(index * arc_length * GOLDEN * PI)/4.15
	var theta = (index * arc_length * GOLDEN * PI) / radius
	
#	if index % 5 == 0: print(index, ", ", radius)
	
	radius = max(0.75, radius)/player.basis.get_scale().x
	
	return Vector3(radius * cos(theta), 0.0, radius * sin(theta))
