extends StaticBody3D

@onready var area := $Area3D
@onready var anim_tree := $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if area.has_overlapping_bodies() or area.has_overlapping_areas():
		anim_tree.set("parameters/conditions/grow", true)
