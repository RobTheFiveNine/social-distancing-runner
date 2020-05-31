extends Node2D

var last_encounter_won = false

func _ready():
	pass

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
