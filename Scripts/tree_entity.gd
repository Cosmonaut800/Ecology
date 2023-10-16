extends StaticBody3D

@onready var area := $Area3D
@onready var anim_tree := $AnimationTree

signal tree_touched()
var touched := false

func _physics_process(_delta):
	if area.has_overlapping_bodies() or area.has_overlapping_areas():
		if not touched:
			touched = true
			tree_touched.emit()
		anim_tree.set("parameters/conditions/grow", true)
