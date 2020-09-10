extends Control

onready var start_button = $CenterContainer/VBoxContainer/StartButton
onready var load_button  = $CenterContainer/VBoxContainer/LoadButton
onready var quit_button  = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	get_tree().paused = false
	VisualServer.set_default_clear_color(Color.black)
	start_button.connect("pressed", self, "_on_StartButton_pressed")
	load_button.connect("pressed", self, "_on_LoadButton_pressed")
	quit_button.connect("pressed", self, "_on_QuitButton_pressed")

func _on_StartButton_pressed():
	SaverAndLoader.reset_custom_data()
	SoundFX.play("Click", 1, -10)
	get_tree().change_scene("res://World.tscn")

func _on_LoadButton_pressed():
	SoundFX.play("Click", 1, -10)
	SaverAndLoader.is_loading = true
	get_tree().change_scene("res://World.tscn")

func _on_QuitButton_pressed():
	SoundFX.play("Click", 1, -10)
	get_tree().quit()
