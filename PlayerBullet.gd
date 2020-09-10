extends "res://Projectile.gd"

func _ready():
	SoundFX.play("Bullet", rand_range(0.8, 1.1))
	set_process(false)
