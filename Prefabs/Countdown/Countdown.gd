extends Node2D

class_name Countdown

signal finished

var player : AnimationPlayer

func _ready():
	player = get_node("AnimationPlayer")

func reset():
	player.seek(0, true)

func start():
	player.play("Pulse")
	get_node("Timer").start()

func _on_timer_timeout():
	emit_signal("finished")
