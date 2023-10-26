extends Node3D

@export var player_body :CharacterBody3D
@export var graphics_anim :AnimationTree
@export var tree_anim :AnimationTree
@export var trigger :Area3D
@export var fall_sound :AudioStreamPlayer3D
@export var MAX_HEALTH := 100.0
@export var num_of_followers := 1
var health := 100.0

@onready var health_bar := $SubViewport/HealthBar

var killed := false

signal spawn_follower(amount: int, spawn_position: Vector3)

func _ready():
	health = MAX_HEALTH
	health_bar.max_value = MAX_HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if trigger.overlaps_body(player_body):
		health -= delta
	
	if health < 0.01 and not killed:
		fall_sound.play()
		spawn_follower.emit(num_of_followers, global_position)
		graphics_anim.set("parameters/conditions/fall", true)
		tree_anim.set("parameters/conditions/grow", true)
		killed = true

func _process(_delta):
	health_bar.value = health

func on_kill_healthbars():
	health_bar.hide()
