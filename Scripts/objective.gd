extends Node3D

var health := 100.0

@export var player_body :CharacterBody3D
@export var MAX_HEALTH := 100.0

@onready var trigger := $Area3D

signal spawn_follower(amount: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if trigger.overlaps_body(player_body):
		health -= player_body.herd_size * delta
	
	if health < 0.0:
		spawn_follower.emit(1)
		health = 100.0
