extends KinematicBody2D

const DustEffect = preload("res://DustEffect.tscn")
const PlayerBullet = preload("res://PlayerBullet.tscn")
const JumpEffect = preload("res://JumpEffect.tscn")
const WallDustEffect = preload("res://WallSlideEffect.tscn")
const PlayerMissile = preload("res://PlayerMissile.tscn")

var PlayerStats = ResourceLoader.PlayerStats
var MainInstances = ResourceLoader.MainInstances

export (Resource) var player_stats_resource

enum {
	MOVE,
	WALL_SLIDE
}

var state = MOVE
var invincible = false setget set_invincible
var motion = Vector2.ZERO
var snap_vector = Vector2.ZERO
var just_jumped = false
var double_jump = true

onready var sprite = $Sprite
onready var sprite_animator = $SpriteAnimator
onready var coyote_jump_timer = $CoyoteJumpTimer
onready var gun = $Sprite/PlayerGun
onready var muzzle = $Sprite/PlayerGun/Sprite/Muzzle
onready var fire_bullet_timer = $FireBulletTimer
onready var blink_animator = $BlinkAnimator
onready var camera_follow = $CameraFollow

# warning-ignore:unused_signal
signal hit_door(door)
signal player_died

func set_invincible(value):
	invincible = value

func _ready():
	self.player_stats_resource = PlayerStatsResource.new({})
	PlayerStats.connect("player_died", self, "_on_died")
	PlayerStats.missiles_unlocked = SaverAndLoader.custom_data.missiles_unlocked
	MainInstances.Player = self
	call_deferred("assign_world_camera")

func queue_free():
	MainInstances.Player = null
	.queue_free()

func _physics_process(delta):
	just_jumped = false

	match state:
		MOVE:
			var input_vector = get_input_vector()
		
			apply_horizontal_accel(input_vector, delta)
			apply_friction(input_vector)
			update_snap_vector()
			apply_jump()
			apply_gravity(delta)
			update_animations(input_vector)
			move()
			wall_slide_check()
		WALL_SLIDE:
			sprite_animator.play("WallSlide")
			
			var wall_axis = get_wall_axis()
			if wall_axis != 0:
				sprite.scale.x = wall_axis
			wall_slide_jump_check(wall_axis)
			wall_slide_drop(delta)
			move()
			wall_detach(delta, wall_axis)
	
	if Input.is_action_pressed("fire") and fire_bullet_timer.time_left == 0:
		fire_bullet()
	
	if Input.is_action_pressed("fire_missile") and fire_bullet_timer.time_left == 0:
		if PlayerStats.missiles > 0 and PlayerStats.missiles_unlocked:
			fire_missile()

func assign_world_camera():
	camera_follow.remote_path = MainInstances.WorldCamera.get_path()

func save():
	return {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"position_x": position.x,
		"position_y": position.y
	}

func fire_bullet():
	var bullet = Utils.instance_scene_on_main(PlayerBullet, muzzle.global_position)
	bullet.velocity = Vector2.RIGHT.rotated(gun.rotation) * player_stats_resource.bullet_speed
	bullet.velocity.x *= sprite.scale.x
	bullet.rotation = bullet.velocity.angle()
	fire_bullet_timer.start()

func fire_missile():
	var missile = Utils.instance_scene_on_main(PlayerMissile, muzzle.global_position)
	missile.velocity = Vector2.RIGHT.rotated(gun.rotation) * player_stats_resource.missile_bullet_speed
	missile.velocity.x *= sprite.scale.x
	motion -= missile.velocity * 0.25
	missile.rotation = missile.velocity.angle()
	fire_bullet_timer.start()
	PlayerStats.missiles -= 1

func create_dust_effect():
	SoundFX.play("Step", rand_range(0.6, 1.2), -10)
	var dust_position = global_position
	dust_position.x += rand_range(-4, 4)
	Utils.instance_scene_on_main(DustEffect, dust_position)

func reset_motion():
	motion = Vector2.ZERO

func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	return input_vector

func apply_horizontal_accel(input_vector, delta):
	if input_vector.x != 0:
		motion.x += input_vector.x * player_stats_resource.acceleration * delta
		motion.x = clamp(motion.x, -player_stats_resource.max_speed, player_stats_resource.max_speed)

func apply_friction(input_vector):
	if input_vector.x == 0 and is_on_floor():
		motion.x = lerp(motion.x, 0, player_stats_resource.friction)
	if input_vector.x == 0 and !is_on_floor():
		motion.x = lerp(motion.x, 0, player_stats_resource.air_friction)

func apply_gravity(delta):
	if not is_on_floor():
		motion.y += player_stats_resource.gravity * delta
		motion.y = min(motion.y, player_stats_resource.jump_force)

func update_snap_vector():
	if is_on_floor():
		snap_vector = Vector2.DOWN

func apply_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0:
		if Input.is_action_just_pressed("ui_up"):
			jump(player_stats_resource.jump_force)
			just_jumped = true
	else:
		if Input.is_action_just_released("ui_up") and motion.y < -player_stats_resource.jump_force/2:
			snap_vector = Vector2.ZERO
			motion.y = -player_stats_resource.jump_force/2
		if Input.is_action_just_pressed("ui_up") and double_jump:
			jump(player_stats_resource.jump_force * .75)
			double_jump = false

func jump(force):
	SoundFX.play("Jump", rand_range(0.6, 1.0))
	Utils.instance_scene_on_main(JumpEffect, global_position)
	just_jumped = true
	snap_vector = Vector2.ZERO
	motion.y = -force

func update_animations(input_vector):
	var facing = sign(get_local_mouse_position().x)
	if facing != 0:
		sprite.scale.x = facing
	if input_vector.x != 0:
		sprite_animator.playback_speed = input_vector.x * sprite.scale.x
		sprite_animator.play("Run")
	else:
		sprite_animator.playback_speed = 1
		sprite_animator.play("Idle")

	if not is_on_floor():
		sprite_animator.play("Jump")

func move():
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	var last_position = position
	var last_motion = motion

	motion = move_and_slide_with_snap(motion, snap_vector * 4, Vector2.UP, true, 4, deg2rad(player_stats_resource.max_slope_angle))

	# landing
	if was_in_air and is_on_floor():
		motion.x = last_motion.x
		Utils.instance_scene_on_main(JumpEffect, global_position)
		double_jump = true

	# just left the ground
	if was_on_floor and not is_on_floor() and not just_jumped:
		motion.y = 0
		position.y = last_position.y
		coyote_jump_timer.start()
	
	# prevent sliding (hack)
	if is_on_floor() and get_floor_velocity().length() == 0 and abs(motion.x) < 1:
		position.x = last_position.x

func wall_slide_check():
	if not is_on_floor() and is_on_wall():
		state = WALL_SLIDE
		double_jump = true
		create_dust_effect()

func get_wall_axis():
	var is_right_wall = test_move(transform, Vector2.RIGHT)
	var is_left_wall = test_move(transform, Vector2.LEFT)
	return int(is_left_wall) - int(is_right_wall)

func wall_slide_jump_check(wall_axis):
	if Input.is_action_just_pressed("ui_up"):
		SoundFX.play("Jump", rand_range(0.6, 1.0))
		motion.x = wall_axis * player_stats_resource.max_speed
		motion.y = -player_stats_resource.jump_force/1.25
		state = MOVE
		var dust_position = global_position + Vector2(wall_axis * 4, -2)
		var dust = Utils.instance_scene_on_main(WallDustEffect, dust_position)
		dust.scale.x = wall_axis

func wall_slide_drop(delta):
	var slide_speed = player_stats_resource.wall_slide_speed
	if Input.is_action_pressed("ui_down"):
		slide_speed = player_stats_resource.max_wall_slide_speed
	motion.y = min(motion.y + player_stats_resource.gravity * delta, slide_speed)

func wall_detach(delta, wall_axis):
	if Input.is_action_just_pressed("ui_right"):
		motion.x = player_stats_resource.acceleration * delta
		state = MOVE

	if Input.is_action_just_pressed("ui_left"):
		motion.x = -player_stats_resource.acceleration * delta
		state = MOVE

	if wall_axis == 0 or is_on_floor():
		state = MOVE

func _on_Hurtbox_hit(damage):
	if not invincible:
		SoundFX.play("Hurt", rand_range(0.6, 1.1))
		PlayerStats.health -= damage
		blink_animator.play("Blink")

func _on_died():
	emit_signal("player_died")
	queue_free()

func _on_PowerupDetector_area_entered(area):
	if area is Powerup:
		area._pickup()
