extends "res://Enemy.gd"

const EnemyBullet = preload("res://EnemyBullet.tscn")

export (int) var BULLET_SPEED = 30
export (float) var SPREAD = 30

onready var fire_direction = $FireDirection
onready var bullet_spawn_point = $BulletSpawnPoint

func fire_bullet():
	var bullet = Utils.instance_scene_on_main(EnemyBullet, bullet_spawn_point.global_position)
	var velocity = (fire_direction.global_position - global_position).normalized() * BULLET_SPEED
	velocity = velocity.rotated(deg2rad(rand_range(-SPREAD, SPREAD)))
	bullet.velocity = velocity
