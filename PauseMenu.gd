extends ColorRect

var paused = false setget set_paused

onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
onready var quit_game_button = $CenterContainer/VBoxContainer/QuitGameButton
onready var quit_menu_button = $CenterContainer/VBoxContainer/QuitMenuButton

func _ready():
	visible = false
	resume_button.connect("pressed", self, "_on_ResumeButton_pressed")
	quit_game_button.connect("pressed", self, "_on_QuitGameButton_pressed")
	quit_menu_button.connect("pressed", self, "_on_QuitMenuButton_pressed")

func set_paused(value):
	paused = value
	get_tree().paused = paused
	visible = paused
	if value:
		SoundFX.play("Pause", 1, -10)
	else:
		SoundFX.play("Unpause", 1, -10)


func _process(_delta):
	var is_player_alive = get_tree().get_nodes_in_group("Player").size() > 0
	if Input.is_action_just_pressed("pause") and is_player_alive:
		self.paused = !paused

func _on_ResumeButton_pressed():
	SoundFX.play("Click", 1, -10)
	self.paused = false

func _on_QuitGameButton_pressed():
	SoundFX.play("Click", 1, -10)
	get_tree().quit()

func _on_QuitMenuButton_pressed():
	SoundFX.play("Click", 1, -10)
	get_tree().change_scene("res://StartMenu.tscn")
