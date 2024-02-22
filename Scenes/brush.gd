extends Node2D

@export var texture: Texture2D
@export var bg_texture: Texture2D
@export var brush_size: int = 100

var brush_queue = []

func _ready():
	draw_texture_rect(bg_texture, Rect2(0.0, 0.0, 1024.0, 1024.0), false)

func queue_brush(draw_position: Vector2, color := Color.WHITE):
	brush_queue.push_back([draw_position, color])
	queue_redraw()

func _draw():
	for b in brush_queue:
		draw_texture_rect(texture, Rect2(b[0].x - brush_size/2, b[0].y - brush_size/2, brush_size, brush_size), false, b[1])
	brush_queue = []
