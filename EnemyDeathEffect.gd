extends Node2D

func _ready():
	SoundFX.play("EnemyDie", rand_range(-0.6, 1.2), -10)

func _on_DustEffect9_tree_exited():
	queue_free()
