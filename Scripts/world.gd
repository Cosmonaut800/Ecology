extends Node3D

const GOLDEN = 0.618033 # Golden Ratio

var follower_scene = preload("res://Scenes/follower.tscn")
var follower_instances = []
var follower_targets = []
var follower_thrown = []
var follower_dead = []
var total_thrown = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var objectives_destroyed := 0
var trees_revived := 0

@export var objectives: Array[Node3D]= []
@export var enemies: Array[Node3D]= []
@export var trees: Array[Node3D]= []
@onready var player = $Player
@onready var ground_paint_controller = $GroundPaintController
@onready var num_structures := $CanvasLayer/Control/NumStructures
@onready var num_trees := $CanvasLayer/Control/NumTrees
@onready var num_ground := $CanvasLayer/Control/NumGround

# Called when the node enters the scene tree for the first time.
func _ready():
	for objective in objectives:
		objective.spawn_follower.connect(on_spawn_follower)
	
	for enemy in enemies:
		enemy.commit_murder.connect(on_commit_murder)
	
	for tree in trees:
		tree.tree_touched.connect(on_tree_touched)
	
	player.throw_follower.connect(on_throw_follower)

func on_spawn_follower(amount, spawn_position):
	objectives_destroyed += 1
	
	for i in amount:
		follower_instances.append(follower_scene.instantiate())
		follower_instances[-1].landed.connect(on_follower_land)
		follower_instances[-1].died.connect(on_follower_die)
		follower_instances[-1].instance_index = follower_instances.size()-1
		follower_instances[-1].position = spawn_position
		follower_instances[-1].player = player
		follower_instances[-1].instance_index = follower_instances.size()-1
		follower_targets.append(Node3D.new())
		follower_targets[-1].position = find_spiral_position(follower_instances.size())
		player.add_child(follower_targets[-1])
		add_child(follower_instances[-1])
		follower_instances[-1].set_leader(follower_targets[-1])
		player.herd_size += 1
	
	player.change_camera_distance(4.6 + sqrt(player.herd_size)/10.0)
	ground_paint_controller.update_brush_size(follower_targets[-1].position.length())

func find_spiral_position(index: int) -> Vector3:
	var arc_length = 0.612
	var radius = sqrt((index + 8) * arc_length * GOLDEN * PI)/4.0
	var theta = ((index + 8) * arc_length * GOLDEN * PI) / radius

	radius = max(0.75, radius)/player.basis.get_scale().x
	
	return Vector3(radius * cos(theta), 0.0, radius * sin(theta))

func on_throw_follower(_amount, destination):
	if player.herd_size > 1:
		var index := find_usable_follower_index()
		
		if index > -1:
			follower_thrown.append(follower_instances[index])
			total_thrown += 1
			player.herd_size -= 1
			
			follower_thrown[-1].whish.set_pitch_scale(randf_range(0.8, 1.2))
			follower_thrown[-1].whish.play()
			follower_thrown[-1].t = 0.0
			follower_thrown[-1].r0 = follower_thrown[-1].position
			follower_thrown[-1].v0.x = (destination.x - follower_thrown[-1].r0.x)/follower_thrown[-1].AIRTIME
			follower_thrown[-1].v0.y = (destination.y - follower_thrown[-1].r0.y)/follower_thrown[-1].AIRTIME + gravity*follower_thrown[-1].AIRTIME/2.0
			follower_thrown[-1].v0.z = (destination.z - follower_thrown[-1].r0.z)/follower_thrown[-1].AIRTIME
			follower_thrown[-1].state = follower_thrown[-1].THROWN

func on_follower_land(follower):
	follower_thrown.erase(follower)
	player.herd_size += 1

func on_follower_die(follower):
	follower_dead.append(follower)

func on_commit_murder():
	for follower in follower_dead:
		follower_instances.erase(follower)
		follower.queue_free()
	
	follower_dead.clear()
	
	for i in follower_instances.size():
		follower_instances[i].set_leader(follower_targets[i])
	
	follower_targets.resize(follower_instances.size())
	
	ground_paint_controller.update_brush_size(follower_targets[-1].position.length())

func find_usable_follower_index() -> int:
	var index := randi_range(0, follower_instances.size()-1)
	
	for i in follower_instances.size():
		if follower_instances[index].state == follower_instances[index].FOLLOW:
			return index
		else:
			index = (index + 1) % follower_instances.size()
	
	return -1

func on_tree_touched():
	trees_revived += 1

func display_score():
	player.can_anything = false
	num_structures.text = str(objectives_destroyed) + "/13"
	num_trees.text = str(trees_revived) + "/50"
	num_ground.text = str(ground_paint_controller.calculate_score()) + "%"
