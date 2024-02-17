extends Node3D

# Credit to HeartBeast on YouTube for this implementation of
# the Fog of War effect!

const light_texture = preload("res://Materials/Textures/spotlight.png")
const DIMENSION = 1024

@onready var fogs := [$"../Ground/Ground1".get_surface_override_material(0), $"../Ground/Ground2".get_surface_override_material(0), $"../Ground/Ground3".get_surface_override_material(0), $"../Ground/Ground4".get_surface_override_material(0), $"../Player/GrassParticleGrid/GrassParticles".get_process_material()]
@onready var player := $"../Player"
@onready var timer := $Timer
@onready var score_timer := $ScoreTimer
@onready var score_text := $"../CanvasLayer/Percentage"

var fog_image := Image.new()
var fog_texture := ImageTexture.new()
var light_image := light_texture.get_image()
var light_offset := Vector2.ZERO
@export var light_scale := 1.0

var target := Vector2.ZERO

func _ready():
	timer.timeout.connect(on_timer_timeout)
	score_timer.timeout.connect(on_score_timeout)
	fog_image = Image.create(DIMENSION, DIMENSION, false, Image.FORMAT_RGBAH)
	fog_image.fill(Color.BLACK)
	light_image.decompress()
	update_brush_size(0.6)
	fogs[4].set_shader_parameter("playerRadius", 1.0)
	light_image.convert(Image.FORMAT_RGBAH)
	target = Vector2(-fog_image.get_width(), -fog_image.get_height())
	update_fog(target)

func update_fog(new_position):
	var light_rect = Rect2(Vector2.ZERO, Vector2(light_image.get_width(), light_image.get_height()))
	fog_image.blend_rect(light_image, light_rect, new_position - light_offset)
	update_fog_image_texture()

func update_fog_image_texture():
	fog_texture = ImageTexture.create_from_image(fog_image)
	for fog in fogs:
		fog.set_shader_parameter("srcTex", fog_texture)

func _process(_delta):
	target = (DIMENSION/128.0) * Vector2(player.global_position.x, player.global_position.z) + Vector2(DIMENSION/2.0, DIMENSION/2.0)
	fogs[4].set_shader_parameter("playerPosition", player.position)

func on_timer_timeout():
	if player.get_position_delta().length() > 0.01:
		update_fog(target)

func on_score_timeout():
	print("score updated")
	score_text.text = str(calculate_score()) + "%"

func update_brush_size(radius):
	fogs[4].set_shader_parameter("playerRadius", radius)
	radius *= 2.0 * (DIMENSION/2048.0) # Values were initially chosen when fog dimension was set to 2048
	light_image.resize(int(radius*light_scale*light_texture.get_width()), int(radius*light_scale*light_texture.get_height()))
	light_image.fix_alpha_edges()
	light_offset = Vector2(int(radius*light_scale*light_texture.get_width())/2, int(radius*light_scale*light_texture.get_height())/2)

func calculate_score():
	var average_color := 0.0
	var test_image := Image.new()
	
	test_image.copy_from(fog_image)
	
	test_image.resize(16, 16, Image.INTERPOLATE_TRILINEAR)
	for x in range(16):
		for y in range(16):
			average_color += test_image.get_pixel(x, y).r
	
	average_color = average_color / (16 * 16)
	return snapped(average_color * 100.0, 1.0)
