extends CharacterBody3D


const SPEED = 1.0

@export var player: Node3D
@export var health := 10.0
@export var attack_range := 20.0

var timer := 0.0
var dead := false
var death_fade := 1.0
var activated := false

@onready var anim_tree := $Graphics/AnimationTree
@onready var graphics := $Graphics
@onready var health_bar := $SubViewport/HealthBar
@onready var hurtbox := $Graphics/Hurtbox
@onready var clanks := [$Clank1, $Clank2, $Clank3]
@onready var saw := $Saw
@onready var death_sound := $Death

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal commit_murder

func _ready():
	health_bar.max_value = health

func _physics_process(delta):
	timer += delta
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if (player.global_position - global_position).length() < attack_range:
		activated = true
	
	var direction = (player.global_position - global_position).normalized()
	if not dead and activated:
		if (player.global_position - global_position).length() < 2.0:
			anim_tree.set("parameters/BlendTree/StateMachine/conditions/attacking", true)
			
			direction = Vector3.ZERO
		else:
			anim_tree.set("parameters/BlendTree/StateMachine/conditions/attacking", false)
			
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		anim_tree.set("parameters/BlendTree/StateMachine/conditions/walking", get_position_delta().length() > 0.01)
		anim_tree.set("parameters/BlendTree/StateMachine/conditions/not_walking", not get_position_delta().length() > 0.01)
		
		move_and_slide()
		
	if health < 0.1 and not dead:
		death_sound.play()
		saw.stop()
		dead = true
		anim_tree.set("parameters/conditions/dead", true)

func _process(_delta):
	health_bar.value = health;
	
	if Vector3(velocity.x, 0.0, velocity.z).length() > 0.08:
		graphics.look_at(global_position + 100.0 * Vector3(velocity.x, 0.0, velocity.z))

func do_damage():
	if hurtbox.has_overlapping_areas():
		var killed_followers = hurtbox.get_overlapping_areas()
		
		for follower in killed_followers:
			follower.get_parent().die()
		
		commit_murder.emit()
		print("deal damage!")
	pass

func on_kill_healthbars():
	health_bar.hide()

func play_random_clank():
	clanks.pick_random().play()
