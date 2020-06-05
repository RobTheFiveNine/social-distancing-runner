extends KinematicBody2D

export (int) var speed = 600
export (int) var knock_back_strength = 1500
export (int) var jump_strength = 1000
export (int) var fall_strength = 900
export (float) var hang_time = 0.5
export (bool) var ignore_input = false

signal ready_for_encounter(enemy)
signal processed_encounter_result()

var jump_delta = 0
var running = false
var jumping = false
var falling = false
var velocity = Vector2()

var knock_back_x = null
var knock_back_y = null

var in_encounter_with : Covidiot
var animation_player : AnimationPlayer
var jump_audio : AudioStreamPlayer2D

func _ready():
	jump_audio = get_node("JumpAudio")
	animation_player = get_node("AnimationPlayer")
	animation_player.play("Neutral")
	connect_covidiot_events()
	
func _physics_process(delta):
	if not ignore_input:
		handle_vertical_velocity(delta)
		handle_knock_back()
		get_input(delta)	
		move_and_slide(velocity, Vector2.UP)
	
func fall(play_anim = false):
	falling = true
	jumping = false
	velocity.y = fall_strength
	jump_delta = 0
	
	if play_anim and knock_back_x == null:
		animation_player.play("Jump")
		animation_player.seek(0.5, true)
	
func handle_vertical_velocity(delta):
	velocity.y = fall_strength

	if jumping:
		velocity.y = jump_strength * -1
	
		if jump_delta >= hang_time:
			fall()
		else:
			jump_delta += delta
			
	if !jumping and !falling and !is_on_floor():
		fall(true)

	if falling:
		if (is_on_floor()):
			if Input.is_action_pressed("move_right"):
				animation_player.play("Walk_Right")
			else:
				animation_player.play("Neutral")
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

func get_input(delta):
	if knock_back_x:
		return

	if !jumping and !falling:
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			play_animation("Walk_Right")

		if Input.is_action_just_pressed("jump"):
			jump_audio.play()
			animation_player.play("Jump")
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
			animation_player.play("Neutral")

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
		animation_player.play("Knock_Back")
		knock_back_x = position.x - 800
		knock_back_y = position.y - 300
		
	in_encounter_with = null

func connect_covidiot_events():
	for c in get_parent().get_children():
		if c is Covidiot:
			c.player_path = get_path()
			c.connect("found_player", self, "_on_enemy_found_player")
