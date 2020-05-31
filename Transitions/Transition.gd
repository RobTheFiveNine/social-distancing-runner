extends Node2D

signal blanked(tag)
signal unblanked(tag)

var _tag

func _ready():
	pass

func unblank():
	get_node("AnimationPlayer").play("Open")
	
func blank(tag = {}):
	_tag = tag
	get_node("AnimationPlayer").play("Close")

func _on_animation_finished(anim_name):
	if anim_name == "Close":
		emit_signal("blanked", _tag)
	elif anim_name == "Open":
		emit_signal("unblanked", _tag)
