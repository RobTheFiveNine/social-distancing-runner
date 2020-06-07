extends Node2D

var last_encounter_won = false
var smoke : CPUParticles2D
var time_label : Label
var timer : Timer

func _ready():
	get_node("CanvasLayer/Transition").visible = true
	smoke = get_node("Smoke")
	time_label = get_node("CanvasLayer/MarginContainer/GridContainer/TimeLabel")
	timer = get_node("Timer")
	
func _process(delta):
	time_label.text = "TIME\n%.2f" % timer.time_left

func _on_encounter_finished(won):
	last_encounter_won = won
	get_node("CanvasLayer/Transition").blank({
		next_scene = "beach"
	})

func _on_transition_unblanked(tag):
	if tag.next_scene == "beach":
		print("Unpausing")
		get_tree().paused = false
		get_node("Player").process_encounter_result(last_encounter_won)

func _on_transition_blanked(tag):
	if tag.next_scene == "beach":
		get_node("CanvasLayer/Encounter").visible = false
		get_node("CanvasLayer/MarginContainer").visible = true
		get_node("CanvasLayer/Transition").unblank()
	elif tag.next_scene == "encounter":
		get_node("CanvasLayer/MarginContainer").visible = false

func _on_enemy_died(death_location):
	smoke.position = Vector2(
		death_location.x + 5.584,
		death_location.y + 125.78
	)

	smoke.restart()

func _on_Timer_timeout():
	pass # Replace with function body.

func draw_remaining_hp(hp):
	for i in range(hp + 1, 4):
		get_node(
			"CanvasLayer/MarginContainer/GridContainer/HBoxContainer/HP%d" % i
		).modulate = Color(1, 1, 1, 0.23)
		
func end_game():
	pass

func _on_Player_hit(remaining_health):
	if remaining_health == 0:
		_on_enemy_died($Player.position)
		$Player.visible = false
		end_game()
	else:
		draw_remaining_hp(remaining_health)
