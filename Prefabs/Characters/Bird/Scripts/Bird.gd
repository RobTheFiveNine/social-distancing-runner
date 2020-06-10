extends Node2D

class_name Bird

export (int) var speed = 500
export (Vector2) var distance_to_travel = Vector2.LEFT * 8000

onready var tween : Tween = $Tween
onready var container : Node2D = $Container
onready var animation : AnimationPlayer = $AnimationPlayer

func _ready():
	setup_tween()

func _on_Area2D_body_entered(body : Player):
	body.knock_back()

func setup_tween() -> void:
	var duration = distance_to_travel.length() / speed
	tween.interpolate_property(
		container,
		"position",
		Vector2.ZERO,
		distance_to_travel,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		0
	)

func wake_up() -> void:
	animation.play("Fly")
	tween.start()

func _on_Tween_tween_all_completed():
	queue_free()
