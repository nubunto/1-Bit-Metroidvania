extends KinematicBody2D

const EnemyDeathEffect = preload("res://EnemyDeathEffect.tscn")

export (int) var MAX_SPEED = 15

onready var stats = $EnemyStats
onready var animation_player = $AnimationPlayer

var old_animation = ""

var motion = Vector2.ZERO

func _on_Hurtbox_hit(damage):
	stats.health -= damage

func _on_EnemyStats_enemy_died():
	Utils.instance_scene_on_main(EnemyDeathEffect, global_position)
	queue_free()
