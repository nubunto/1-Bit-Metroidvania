extends Node

export (Array, AudioStream) var music_list = []

var music_list_index = 0

onready var music_player = $AudioStreamPlayer

func list_play():
	assert(music_list.size() > 0)
	music_player.stream = music_list[music_list_index]
	music_player.play()
	music_list_index = music_list_index % music_list.size()

func list_stop():
	music_player.stop()

func _on_AudioStreamPlayer_finished():
	list_play()
