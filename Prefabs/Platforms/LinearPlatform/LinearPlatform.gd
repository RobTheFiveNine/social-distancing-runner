extends Node2D

export (float) var idle_duration = 1.0
export (Vector2) var move_to = Vector2.UP * 500
export (float) var speed = 600

onready var platform : KinematicBody2D = $Platform
onready var tween : Tween = $Tween

var target_position = Vector2.ZERO

func _ready():
	var duration = move_to.length() / speed
	tween.interpolate_property(
		self,
		"target_position",
		Vector2.ZERO,
		move_to,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		idle_duration
	)

	tween.interpolate_property(
		self,
		"target_position",
		move_to,
		Vector2.ZERO,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		duration + (idle_duration * 2)
	)

	tween.start()

func _physics_process(_delta):
	platform.position = platform.position.linear_interpolate(target_position, 0.075)
