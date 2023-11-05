@tool
extends EditorScript

const ROWS := 4
const COLUMNS := 4
const TARGET_COORD := Vector2i(0, 2)

var heightmap = Image.new()
var height_intensity := 10.0 # /!\ Make sure this scale matches the shader /!\ 
var collision_shape = get_scene().get_node("./Ground/BorderGround12/StaticBody3D/HeightmapCollision") # /!\ Pick the correct CollisionShape3D /!\


func _run():
	print("Updating heightmap collision")
	heightmap.load("res://Materials/Textures/ecology_heightmap_extended.png") # /!\ Put the heightmap you want to use here /!\
	heightmap.convert(Image.FORMAT_RF)
	
	collision_shape.shape.map_width = 130
	collision_shape.shape.map_depth = 130
	
	assign_map_data()

func assign_map_data():
	var x := 0
	var y := 0
	var x_interval := float(heightmap.get_width()) / float(collision_shape.shape.map_width - 1)
	var y_interval := float(heightmap.get_height()) / float(collision_shape.shape.map_depth - 1)
	var k := 0
	
	print("Transferring data to array of size ", (collision_shape.shape.map_width * collision_shape.shape.map_depth))
	for j in collision_shape.shape.map_depth:
		for i in collision_shape.shape.map_width:
			if k % 100 == 0:
				print(k)
			x = i * x_interval
			y = j * y_interval
			
			x = clamp(x, 0, heightmap.get_width() - 1)
			y = clamp(y, 0, heightmap.get_height() - 1)
			
			collision_shape.shape.map_data[k] = (height_intensity / collision_shape.transform.basis.get_scale().y) * heightmap.get_pixel(x/COLUMNS+(TARGET_COORD.x*(heightmap.get_width()/COLUMNS)), y/ROWS+(TARGET_COORD.y*(heightmap.get_height()/ROWS))).r
			k += 1
	
