extends Node2D

class_name Countdown

signal finished

func start():
	get_node("AnimationPlayer").play("Pulse")
	get_node("Timer").start()

func _on_timer_timeout():
	emit_signal("finished")
