extends Node

var MainInstances = ResourceLoader.MainInstances

onready var current_level = $Level_00
onready var player_death_timer = $PlayerDeathTimer

func _ready():
	VisualServer.set_default_clear_color(Color.black)
	Music.list_play()

	if SaverAndLoader.is_loading:
		SaverAndLoader.load_game()
		SaverAndLoader.is_loading = false

	MainInstances.Player.connect("hit_door", self, "_on_player_hit_door")
	MainInstances.Player.connect("player_died", self, "_on_player_died")

func _on_player_hit_door(door):
	call_deferred("change_levels", door)

func change_levels(door):
	var offset = current_level.position
	current_level.queue_free()
	var NewLevel = load(door.new_level_path)
	var new_level = NewLevel.instance()
	add_child(new_level)
	var new_door = get_door_with_connection(door, door.connection)
	if new_door != null:
		var exit_position = new_door.position - offset
		new_level.position = door.position - exit_position

func get_door_with_connection(not_door, connection):
	var doors = get_tree().get_nodes_in_group("Door")
	for door in doors:
		if door.connection == connection and door != not_door:
			return door
	return null

func _on_player_died():
	player_death_timer.start()

func _on_PlayerDeathTimer_timeout():
	get_tree().change_scene("res://GameOverMenu.tscn")
