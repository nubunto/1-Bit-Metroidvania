extends Resource
class_name PlayerStatsResource

export (int) var acceleration = 512
export (int) var max_speed = 64
export (float) var friction = 0.20
export (float) var air_friction = 0.40
export (int) var gravity = 200
export (int) var wall_slide_speed = 48
export (int) var max_wall_slide_speed  = 128
export (int) var jump_force = 128
export (int) var max_slope_angle = 46
export (int) var bullet_speed = 250
export (int) var missile_bullet_speed = 150

func _init(data_dict):
	var keys = [
		'acceleration',
		'max_speed',
		'friction',
		'air_friction',
		'gravity',
		'wall_slide_speed',
		'max_wall_slide_speed',
		'jump_force',
		'max_slope_angle',
		'bullet_speed',
		'missile_bullet_speed'
	]
	for key in keys:
		if data_dict.has(key):
			set(key, data_dict[key])
