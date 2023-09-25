extends CollisionShape3D

var heightmap = Image.new()
@export var height_intensity := 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	heightmap.load("res://Materials/test_heightmap.png")
	heightmap.convert(Image.FORMAT_RF)
	
	shape.map_width = 34
	shape.map_depth = 34
	
	assign_map_data()

func assign_map_data():
	var x := 0
	var y := 0
	var x_interval := float(heightmap.get_width()) / float(shape.map_width - 1)
	var y_interval := float(heightmap.get_height()) / float(shape.map_depth - 1)
	var k := 0
	
	print("Transferring data to array of size ", (shape.map_width * shape.map_depth))
	for j in shape.map_depth:
		for i in shape.map_width:
			if k % 100 == 0:
				print(k)
			x = i * x_interval
			y = j * y_interval
			
			x = clamp(x, 0, 1023)
			y = clamp(y, 0, 1023)
			
			shape.map_data[k] = (height_intensity / transform.basis.get_scale().y) * heightmap.get_pixel(x, y).r
			k += 1
	
