extends Node3D

# Credit to HeartBeast on YouTube for this implementation of
# the Fog of War effect!

const light_texture = preload("res://Materials/spotlight.png")
const DIMENSION = 512

@onready var fog = $"../Ground".get_surface_override_material(0)
@onready var player = $"../Player"
@onready var timer = $Timer

var fog_image = Image.new()
var fog_texture = ImageTexture.new()
var light_image = light_texture.get_image()
var light_offset = Vector2.ZERO
@export var light_scale := 1.0

var player_last_position := Vector3.ZERO
var target := Vector2.ZERO

func _ready():
	timer.timeout.connect(on_timer_timeout)
	fog_image = Image.create(DIMENSION, DIMENSION, false, Image.FORMAT_RGBAH)
	fog_image.fill(Color.BLACK)
	light_image.decompress()
	update_brush_size(0.6) #light_image.resize(int(player.herd_size*light_scale*light_texture.get_width()), int(player.herd_size*light_scale*light_texture.get_height()))
	#light_offset = Vector2(int(light_scale*light_texture.get_width())/2, int(light_scale*light_texture.get_height())/2)
	light_image.convert(Image.FORMAT_RGBAH)
	target = Vector2(-fog_image.get_width(), -fog_image.get_height())
	update_fog(target)

func update_fog(new_position):
	var light_rect = Rect2(Vector2.ZERO, Vector2(light_image.get_width(), light_image.get_height()))
	fog_image.blend_rect(light_image, light_rect, new_position - light_offset)
	update_fog_image_texture()

func update_fog_image_texture():
	fog_texture = ImageTexture.create_from_image(fog_image)
	fog.set_shader_parameter("srcTex", fog_texture)

func _process(_delta):
	target = (DIMENSION/100.0) * Vector2(player.global_position.x, player.global_position.z) + Vector2(DIMENSION/2.0, DIMENSION/2.0)
	
	player_last_position = player.global_position

func on_timer_timeout():
	if player.is_on_floor() and player.get_position_delta().length() > 0.01:
		update_fog(target)

func update_brush_size(radius):
	radius *= 2.0 * (DIMENSION/2048.0) # Values were initially chosen when fog dimension was set to 2048
	light_image.resize(int(radius*light_scale*light_texture.get_width()), int(radius*light_scale*light_texture.get_height()))
	light_offset = Vector2(int(radius*light_scale*light_texture.get_width())/2, int(radius*light_scale*light_texture.get_height())/2)
