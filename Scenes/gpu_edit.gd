extends MeshInstance3D

const NUM_OF_BRUSHES = 1000

@onready var brush := $SubViewport/Brush

var frame := 0
var colors = []
var offsets = []

func _ready():
	for i in range(NUM_OF_BRUSHES):
		colors.push_back(Color.from_hsv(randf_range(0.0,6.0), 1.0, 1.0))
		offsets.push_back(randf_range(0.5, 1.5))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	frame += 1
	
	for i in range(NUM_OF_BRUSHES):
		var draw_position := Vector2(offsets[i] * 512.0 + offsets[(i+1)%NUM_OF_BRUSHES] * 512.0 * cos(deg_to_rad(offsets[i] * 1.616 * frame)), offsets[i] * 512.0 + offsets[(i+1)%NUM_OF_BRUSHES] * 512.0 * sin(deg_to_rad(offsets[i] * 3.14 * frame)))
		
		brush.queue_brush(draw_position, colors[i])
