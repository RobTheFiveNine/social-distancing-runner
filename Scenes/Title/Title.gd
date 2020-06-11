extends Node2D

signal game_starting()

func _ready():
	$AnimationPlayer.play("Flash")

func _input(event : InputEvent):
	if not event is InputEventKey:
		return

	if !event.is_pressed() or event.is_echo():
		return

	emit_signal("game_starting")

func _on_Transition_blanked(_tag):
	get_tree().change_scene("res://Scenes/Beach/Beach.tscn")
