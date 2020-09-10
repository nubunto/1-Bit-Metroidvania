extends "res://Level.gd"

const PLAYER_BIT = 0b0

onready var boss = $BossEnemy
onready var block_door = $BlockDoor

func _on_Trigger_area_triggered():
	if not SaverAndLoader.custom_data.boss_defeated:
		set_block_door_state(true)

func _on_BossEnemy_died():
	set_block_door_state(false)

func set_block_door_state(state):
	block_door.visible = state
	block_door.set_collision_mask_bit(PLAYER_BIT, state)
