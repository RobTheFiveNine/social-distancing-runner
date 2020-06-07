extends Node2D

class_name Transition

signal blanked(tag)
signal unblanked(tag)

export (bool) var is_blanked = false

var _tag
var animation_player : AnimationPlayer

func _ready():
	animation_player = get_node("AnimationPlayer")
	animation_player.play("Close")

	if is_blanked:
		animation_player.seek(0.5, true)
	else:
		animation_player.seek(0, true)

	animation_player.stop(false)

func unblank():
	animation_player.play("Open")
	
func blank(tag = {}):
	_tag = tag
	animation_player.play("Close")

func _on_animation_finished(anim_name):
	if anim_name == "Close":
		emit_signal("blanked", _tag)
	elif anim_name == "Open":
		emit_signal("unblanked", _tag)
