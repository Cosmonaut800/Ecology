extends Node3D

# Credit to HeartBeast on YouTube for this implementation of
# the Fog of War effect!

const light_texture = preload("res://Materials/spotlight.png")

@onready var fog = $"../Ground".get_surface_override_material(0)
@onready var player = $"../Player"

var fog_image = Image.new()
var fog_texture = ImageTexture.new()
var light_image = light_texture.get_image()
var light_offset = Vector2.ZERO
@export var light_scale := 1.0

var target := Vector2.ZERO

func _ready():
	fog_image = Image.create(2048, 2048, false, Image.FORMAT_RGBAH)
	fog_image.fill(Color.BLACK)
	light_image.decompress()
	light_image.resize(int(light_scale*light_image.get_width()), int(light_scale*light_image.get_height()))
	light_offset = Vector2(int(light_scale*light_texture.get_width())/2, int(light_scale*light_texture.get_height())/2)
	light_image.convert(Image.FORMAT_RGBAH)

func update_fog(new_position):
	var light_rect = Rect2(Vector2.ZERO, Vector2(light_image.get_width(), light_image.get_height()))
	fog_image.blend_rect(light_image, light_rect, new_position - light_offset)
	update_fog_image_texture()

func update_fog_image_texture():
	fog_texture = ImageTexture.create_from_image(fog_image)
	fog.set_shader_parameter("srcTex", fog_texture)

func _process(_delta):
	print("hello?")
	target = (1024.0/50.0) * Vector2(player.global_position.x, player.global_position.z) + Vector2(1024.0, 1024.0)
	update_fog(target)
