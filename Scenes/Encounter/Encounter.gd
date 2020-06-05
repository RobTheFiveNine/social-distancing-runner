extends Node2D

signal encounter_setup
signal encounter_finished(won)

var seconds_to_complete : float
var phrase_index : int
var next_letter : int
var phrase_label : RichTextLabel
var time_label : RichTextLabel
var typos_label : RichTextLabel
var actions : Array
var phrase : String
var typos_made : int
var max_attempts : int
var active : bool
var timer : Timer
var key_sfx_player : AudioStreamPlayer

var phrases = [
	"Bleach is not\ngood for you",
	"Stay at home\nsave lives",
	"5G didn't cause\nthe pandemic",
	"This isn't a distraction\nfrom 5G being rolled out",
	"You shouldn't be socialising\non a crowded beach",
	"Don't drive across the country\nto test your eye sight",
	"If you can squat outside in\nprotest, you can do it at home",
	"Bill Gates has nothing\nto do with this",
	"It isn't Obama's fault",
	"Don't take antimalarial drugs\nwithout your doctor's approval",
	"Wearing masks can protect\nyou and those around you"
]

func _ready():
	phrase_label = get_node("Phrase")
	time_label = get_node("TimeLabel")
	typos_label = get_node("TyposLabel")
	timer = get_node("Timer")
	key_sfx_player = get_node("AudioStreamPlayer")
	get_node("EnemyPlaceHolder").visible = false
	
func _process(delta):
	if active:
		update_time_remaining()
		
func _input(event):
	if not visible or not active:
		return

	if not event is InputEventKey:
		return
		
	if !event.is_pressed() or event.is_echo():
		return

	if event.scancode < 256 and event.scancode != 32:
		process_key_stroke(char(event.unicode))
		
func update_time_remaining(value = null):
	time_label.clear()
	time_label.push_align(RichTextLabel.ALIGN_RIGHT)
	time_label.append_bbcode("TIME REMAINING: ")
	
	if not value:
		time_label.append_bbcode("%.2f" % timer.time_left)
	else:
		time_label.append_bbcode("%.2f" % value)
	
func draw_typos_remaining():
	typos_label.clear()
	typos_label.append_bbcode(str(max(max_attempts - typos_made, 0)))
	typos_label.append_bbcode(" TYPOS REMAINING")

func draw_phrase():
	phrase_label.clear()
	phrase_label.push_align(RichTextLabel.ALIGN_CENTER)
	
	for i in range(0, len(phrase)):
		if i < len(actions):
			if actions[i]:
				phrase_label.push_color(Color.green)
			else:
				phrase_label.push_color(Color.red)
		else:
			phrase_label.push_color(Color.white)
		
		phrase_label.append_bbcode(phrase[i].to_upper())
		
func process_key_stroke(key_char):
	key_sfx_player.play()

	var result = phrase[next_letter].nocasecmp_to(key_char) == 0
	actions.append(result)
	
	if !result:
		typos_made += 1
		
	draw_typos_remaining()
	
	if !result and typos_made > max_attempts:
		finish(false)
	else:
		if next_letter == len(phrase) - 1:
			finish(true)
		else:
			if phrase[next_letter + 1] == " " or phrase[next_letter + 1] == "\n":
				actions.append(true)
				next_letter += 2
			else:
				next_letter += 1
		
	draw_phrase()
	
func finish(won):
	active = false
	timer.stop()
	emit_signal("encounter_finished", won)
	
func setup_enemy_sprite(enemy):
	var current = get_node("Enemy")
	if current:
		current.queue_free()

	var e : Covidiot = enemy.duplicate(DUPLICATE_USE_INSTANCING)
	e.name = "Enemy"
	e.collision_layer = 0
	e.collision_mask = 0
	e.position = get_node("EnemyPlaceHolder").rect_position
	e.ignore_physics = true
	e.pursuit = false

	add_child(e)
	
func roll_new_encounter(enemy):
	setup_enemy_sprite(enemy)

	randomize()

	actions = []
	max_attempts = max(rand_range(1, 10), 3)
	typos_made = 0
	
	seconds_to_complete = ceil(rand_range(3, 10))
	timer.wait_time = seconds_to_complete
	timer.one_shot = true

	phrase_index = rand_range(0, len(phrases) - 1)
	phrase = phrases[phrase_index]

	next_letter = 0
	phrase_label.clear()
	phrase_label.push_align(RichTextLabel.ALIGN_CENTER)
	phrase_label.append_bbcode(phrase.to_upper())
	
	update_time_remaining(seconds_to_complete)
	draw_typos_remaining()
	
	visible = true

	emit_signal("encounter_setup")

func start():
	active = true
	timer.start()

func _on_transition_blanked(tag):
	if tag.next_scene == "encounter":
		get_node("Countdown").reset()
		roll_new_encounter(tag.enemy)

func _on_transition_unblanked(tag):
	if tag.next_scene == "encounter":
		get_node("Countdown").start()

func _on_countdown_finished():
	start()

func _on_timer_timeout():
	finish(false)
