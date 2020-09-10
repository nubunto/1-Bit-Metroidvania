extends StaticBody2D

var PlayerStats = ResourceLoader.PlayerStats

onready var animation_player = $AnimationPlayer

func _on_SaveArea_body_entered(_body):
	SoundFX.play("Powerup", 0.6, -10)
	animation_player.play("Save")
	SaverAndLoader.save_game()
	PlayerStats.reset_stats()
