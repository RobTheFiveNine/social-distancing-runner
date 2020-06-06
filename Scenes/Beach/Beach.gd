extends Node2D

var last_encounter_won = false
var smoke : CPUParticles2D

func _ready():
	get_node("CanvasLayer/Transition").visible = true
	smoke = get_node("Smoke")

func _on_encounter_finished(won):
	last_encounter_won = won
	get_node("CanvasLayer/Transition").blank({
		next_scene = "beach"
	})

func _on_transition_unblanked(tag):
	print("beach:unblanked")
	print(tag)
	if tag.next_scene == "beach":
		print("Unpausing")
		get_tree().paused = false
		get_node("Player").process_encounter_result(last_encounter_won)

func _on_transition_blanked(tag):
	if tag.next_scene == "beach":
		get_node("CanvasLayer/Encounter").visible = false
		get_node("CanvasLayer/Transition").unblank()

func _on_enemy_died(death_location):
	smoke.position = Vector2(
		death_location.x + 5.584,
		death_location.y + 125.78
	)

	smoke.restart()

