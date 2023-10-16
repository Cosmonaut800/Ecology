extends Node3D

const AIRTIME = 1.0

var leader = null
var player
var instance_index := 0
@onready var ray := $RayCast3D
@onready var graphics := $Graphics
@onready var trigger := $Area3D
@onready var whish := $Whish
@onready var thud := $Thud

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vertical_velocity := 0.0
var random_offset := randf_range(0.0, 2 * PI)
var last_position := Vector3.ZERO
var speed := 5.0 # randf_range(4.8, 5.2)

enum {FOLLOW, THROWN, COOLDOWN, RETURN}
var state = FOLLOW
@export var cooldown_time := 5.0
var cooldown_timer := 5.0
var r0 := Vector3.ZERO
var v0 := Vector3.ZERO
var t := 0.0

signal landed(follower)
signal died(follower)

func _ready():
	cooldown_timer = cooldown_time
	last_position = position

func _physics_process(delta):
	var target_pos = Vector3(leader.global_position.x, position.y, leader.global_position.z)
	
	if state == FOLLOW or state == RETURN:
		position = position.move_toward(target_pos, speed * delta)
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
		
		if state == RETURN and (position - Vector3(leader.global_position.x, position.y, leader.global_position.z)).length() < 0.01:
			state = FOLLOW
	
	if state == THROWN:
		position = r0 + v0*t + Vector3(0.0, -gravity, 0.0)*t*t/2.0
		
		if t > AIRTIME:
			landed.emit(self)
			thud.set_pitch_scale(randf_range(0.8, 1.2))
			thud.play()
			target_pos = ray.get_collision_point() + 0.25 * Vector3.UP
			position = target_pos
			if trigger.has_overlapping_areas():
				var triggered_areas = trigger.get_overlapping_areas()
				for triggered in triggered_areas:
					triggered.get_parent().health -= 1
			state = COOLDOWN
		
		t += delta
	
	if state == COOLDOWN:
		cooldown_timer -= delta
		if cooldown_timer < 0.0:
			cooldown_timer = cooldown_time
			state = RETURN

func _process(_delta):
	var look_dir: Vector3
	
	if (position - last_position).length() > 0.01:
		graphics.position.y = 0.05 * sin(20.0 * player.timer + random_offset)
		look_dir = position + (5.0 * (position - last_position).normalized() * Vector3(1.0, 0.0, 1.0))
		if (look_dir - position).length() > 0.01:
			graphics.look_at(look_dir)
	else:
		graphics.position.y = 0.0
		if state != COOLDOWN:
			graphics.basis = Basis.from_euler(player.graphics.basis.get_euler()).scaled(0.5*Vector3.ONE)
	
	last_position = position

func set_leader(target_leader: Node3D):
	leader = target_leader

func die():
	print("received damage!")
	died.emit(self)
