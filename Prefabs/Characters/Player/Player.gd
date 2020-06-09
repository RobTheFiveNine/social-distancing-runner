extends KinematicBody2D

class_name Player

export (int) var speed = 600
export (int) var knock_back_strength = 1500
export (int) var jump_strength = 1000
export (int) var fall_strength = 900
export (float) var hang_time = 0.5
export (bool) var ignore_input = false
export (int) var health = 3
export (int) var limit_bottom = 2550

signal ready_for_encounter(enemy)
signal hit(remaining_health, player_position)

var initial_speed
var initial_jump_strength
var initial_fall_strength
var jump_delta = 0
var running = false
var jumping = false
var falling = false
var velocity = Vector2()
var energy_timer : Timer

var knock_back_x = null
var knock_back_y = null

var in_encounter_with : Covidiot
var animation_player : AnimationPlayer
var jump_audio : AudioStreamPlayer2D
var floor_ray : RayCast2D

func _ready():
	initial_speed = speed
	initial_fall_strength = fall_strength
	initial_jump_strength = jump_strength
	energy_timer = get_node("EnergyBoostTimer")
	jump_audio = get_node("JumpAudio")
	animation_player = get_node("AnimationPlayer")
	floor_ray = get_node("FloorRayCast")
	play_animation("Neutral")

func is_on_ground_or_platform():
	return is_on_floor() or floor_ray.is_colliding()
	
func _physics_process(delta):
	if not ignore_input:
		handle_vertical_velocity(delta)
		handle_knock_back()
		get_input(delta)

		var snap = Vector2.DOWN * 20 if !jumping else Vector2.ZERO
		move_and_slide_with_snap(velocity, snap, Vector2.UP)
		
		if position.y >= limit_bottom:
			die()
	
func die():
	collision_layer = 0
	ignore_input = true
	emit_signal("hit", 0, position)
	visible = false

func fall(play_anim = false):
	falling = true
	jumping = false
	velocity.y = fall_strength
	jump_delta = 0
	
	if play_anim and knock_back_x == null:
		play_animation("Jump")
		animation_player.seek(0.5, true)
	
func handle_vertical_velocity(delta):
	if !is_on_ground_or_platform():
		velocity.y = fall_strength
	else:
		velocity.y = 0

	if jumping:
		velocity.y = jump_strength * -1
	
		if jump_delta >= hang_time:
			fall()
		else:
			jump_delta += delta
			
	if !jumping and !falling and !is_on_ground_or_platform():
		fall(true)

	if falling:
		if is_on_ground_or_platform():
			if knock_back_x == null:
				if Input.is_action_pressed("move_right"):
					play_animation("Walk_Right")
				else:
					play_animation("Neutral")
			falling = false
			
func play_animation(name):
	if animation_player.current_animation != name:
		animation_player.play(name)

func handle_knock_back():
	if not knock_back_x:
		return

	if position.x <= knock_back_x:
		knock_back_x = null
	else:
		velocity.x = knock_back_strength * -1
		
	if knock_back_y:
		if position.y <= knock_back_y:
			knock_back_y = null
		else:
			velocity.y = knock_back_strength * -1

func get_input(_delta):
	if knock_back_x:
		return

	if !jumping and !falling:
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			play_animation("Walk_Right")

		if Input.is_action_just_pressed("jump"):
			jump_audio.play()
			play_animation("Jump")
			jumping = true
			jump_delta = 0
			velocity.y = jump_strength

	if Input.is_action_pressed("move_right"):
		velocity.x = speed
	elif Input.is_action_pressed("move_left"):
		velocity.x = speed * -1
	else:
		velocity.x = 0

		if !falling and !jumping and animation_player.current_animation != 'Neutral':
			play_animation("Neutral")

func _on_enemy_found_player(enemy : Covidiot):
	in_encounter_with = enemy
	get_tree().paused = true
	emit_signal("ready_for_encounter", {
		next_scene = "encounter",
		enemy = enemy
	})

func process_encounter_result(won):
	if won:
		in_encounter_with.die()
	else:
		health = health - 1
		emit_signal("hit", health, position)

		if health == 0:
			die()
		else:
			get_node("Hit").play()
			play_animation("Knock_Back")
			knock_back_x = position.x - 800
			knock_back_y = position.y - 300
		
	in_encounter_with = null

func use_energy_boost():
	if energy_timer.is_stopped():
		speed = speed * 1.8
		jump_strength = jump_strength * 1.8
		fall_strength = fall_strength * 1.8

	$EnergyBoostTimer.start()
	$EnergyBoostAnimation.play("Pulse")

func _on_EnergyBoostTimer_timeout():
	speed = initial_speed
	jump_strength = initial_jump_strength
	fall_strength = initial_fall_strength
	$EnergyBoostAnimation.stop()
	$Sprites.modulate = Color(1, 1, 1, 1)
