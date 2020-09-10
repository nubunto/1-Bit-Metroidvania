extends "res://Projectile.gd"

const EnemyDeathEffect = preload("res://EnemyDeathEffect.tscn")

const BRICK_LAYER_BIT = 4

onready var ignition_timer = $IgnitionTimer

func _ready():
	ignition_timer.connect("timeout", self, "_on_IgnitionTimer_timeout")
	ignition_timer.start()
	SoundFX.play("Explosion", rand_range(0.8, 1.1))
	set_process(false)

func _on_Hitbox_body_entered(body):
	if body.get_collision_layer_bit(BRICK_LAYER_BIT):
		body.queue_free()
		Utils.instance_scene_on_main(EnemyDeathEffect, body.global_position + Vector2(8, 8))
	._on_Hitbox_body_entered(body)

func _on_IgnitionTimer_timeout():
	set_process(true)
