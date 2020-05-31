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

var phrases = [
	"Bleach is not good for you",
	"Stay at home, save lives",
	"5G didn't cause the pandemic",
	"This isn't a distraction from 5G being rolled out",
	"You shouldn't be socialising on a crowded beach",
	"Don't drive across the country to test your eye sight",
	"If you can squat outside in protest, you can do it at home",
	"Bill Gates has nothing to do with this",
	"It isn't Obama's fault",
	"Don't take antimalarial drugs\nwithout your doctor's approval",
	"Wearing masks can protect you and those around you"
]

func _ready():
	phrase_label = get_node("Phrase")
	time_label = get_node("TimeLabel")
	typos_label = get_node("TyposLabel")
	pass
		
func _input(event):
	if not visible:
		return

	if not event is InputEventKey:
		return
		
	if !event.is_pressed() or event.is_echo():
		return

	if event.scancode < 256 and event.scancode != 32:
		process_key_stroke(char(event.unicode))
		
func update_time_remaining(delta):
	seconds_to_complete -= delta
	time_label.clear()
	time_label.push_align(RichTextLabel.ALIGN_RIGHT)
	time_label.append_bbcode("TIME REMAINING: ")
	time_label.append_bbcode("%.2f" % seconds_to_complete)
	
func draw_typos_remaining():
	typos_label.clear()
	typos_label.append_bbcode(str(max_attempts - typos_made))
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
	var result = phrase[next_letter].nocasecmp_to(key_char) == 0
	actions.append(result)
	
	if !result and typos_made == max_attempts:
		finish(false)
	else:
		if next_letter == len(phrase) - 1:
			# get_tree().root.get_node("Globals").set_next_scene("test")
			finish(true)
		else:
			if phrase[next_letter + 1] == " " or phrase[next_letter + 1] == "\n":
				actions.append(true)
				next_letter += 2
			else:
				next_letter += 1
		
	draw_phrase()
	
func finish(won):
	emit_signal("encounter_finished", won)
	
func roll_new_encounter(enemy):
	print(enemy.name)
	randomize()

	actions = []
	max_attempts = max(rand_range(1, 10), 3)
	typos_made = 0
	
	seconds_to_complete = ceil(rand_range(2, 10))
	phrase_index = 9 #rand_range(0, len(phrases) - 1)
	phrase = phrases[phrase_index]

	next_letter = 0
	phrase_label.clear()
	phrase_label.push_align(RichTextLabel.ALIGN_CENTER)
	phrase_label.append_bbcode(phrase.to_upper())
	
	update_time_remaining(0)
	draw_typos_remaining()
	
	visible = true

	emit_signal("encounter_setup")

func start():
	print("start encounter")

func _on_transition_blanked(tag):
	if tag.next_scene == "encounter":
		roll_new_encounter(tag.enemy)

func _on_transition_unblanked(tag):
	if tag.next_scene == "encounter":
		get_node("Countdown").start()

func _on_countdown_finished():
	start()
