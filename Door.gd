extends Area2D

export (Resource) var connection = null
export (String, FILE, "*.tscn") var new_level_path = ""
var active = true

func _on_Door_body_entered(player):
	if active == true:
		player.emit_signal("hit_door", self)
		active = false
