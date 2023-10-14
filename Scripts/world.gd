extends Node3D

const GOLDEN = 0.618033 # Golden Ratio

var follower_scene = preload("res://Scenes/follower.tscn")
var follower_instances = []
var follower_targets = []
var follower_thrown = []
var follower_dead = []
var total_thrown = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var objectives: Array[Node3D]= []
@export var enemies: Array[Node3D]= []
@onready var player = $Player
@onready var ground_paint_controller = $GroundPaintController

# Called when the node enters the scene tree for the first time.
func _ready():
	for objective in objectives:
		objective.spawn_follower.connect(on_spawn_follower)
	
	for enemy in enemies:
		enemy.commit_murder.connect(on_commit_murder)
	
	player.throw_follower.connect(on_throw_follower)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(_delta):
#	pass

func on_spawn_follower(amount, spawn_position):
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
	var radius = sqrt((index + 8) * arc_length * GOLDEN * PI)/4.15
	var theta = ((index + 8) * arc_length * GOLDEN * PI) / radius
	
#	if index % 5 == 0:
#		print(index, ", ", radius)
	
	radius = max(0.75, radius)/player.basis.get_scale().x
	
	return Vector3(radius * cos(theta), 0.0, radius * sin(theta))

func on_throw_follower(amount, destination):
	if player.herd_size > 1:
		var index := find_usable_follower_index()
		
		if index > -1:
			follower_thrown.append(follower_instances[index])
			total_thrown += 1
			player.herd_size -= 1
			
			follower_thrown[-1].t = 0.0
			follower_thrown[-1].r0 = follower_thrown[-1].position
			follower_thrown[-1].v0.x = (destination.x - follower_thrown[-1].r0.x)/follower_thrown[-1].AIRTIME
			follower_thrown[-1].v0.y = (destination.y - follower_thrown[-1].r0.y)/follower_thrown[-1].AIRTIME + gravity*follower_thrown[-1].AIRTIME/2.0
			follower_thrown[-1].v0.z = (destination.z - follower_thrown[-1].r0.z)/follower_thrown[-1].AIRTIME
			follower_thrown[-1].state = follower_thrown[-1].THROWN

func on_follower_land(follower):
	follower_thrown.erase(follower)
	player.herd_size += 1
	pass

func on_follower_die(follower):
	follower_dead.append(follower)

func on_commit_murder():
	print("killing ", follower_dead.size(), " followers!")
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

func sort_thrown_followers(a, b):
	if a.state == a.FOLLOW:
		return false
	else:
		return true
