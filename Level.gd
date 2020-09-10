extends Node2D

const WORLD = preload("res://World.gd")

func _ready():
	var parent = get_parent()
	if parent is WORLD:
		parent.current_level = self

func save():
	return {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"position_x": position.x,
		"position_y": position.y
	}
