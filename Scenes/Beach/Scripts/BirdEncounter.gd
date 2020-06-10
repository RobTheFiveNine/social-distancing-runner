extends Node2D

onready var bird_container = $Birds
onready var activation_area : Area2D = $ActivationArea

func _on_ActivationArea_body_entered(_body):
	print("Starting encounter")
	activation_area.set_monitoring(false)
	for bird in bird_container.get_children():
		bird.wake_up()
