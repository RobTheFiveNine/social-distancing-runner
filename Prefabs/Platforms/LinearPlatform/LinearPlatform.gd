extends Node2D

export (float) var idle_duration = 1.0
export (Vector2) var move_to = Vector2.UP * 500
export (float) var speed = 600
export (bool) var can_spawn_items = true
export (float, 0, 1) var item_spawn_chance = 0.1
export (String) var item_type_to_load = null

onready var platform : KinematicBody2D = $Platform
onready var tween : Tween = $Tween

var target_position = Vector2.ZERO

func _ready():
	setup_spawn_point()
	setup_tween()

func _physics_process(_delta):
	platform.position = platform.position.linear_interpolate(target_position, 0.075)

func setup_tween():
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

func setup_spawn_point() -> void:
	var spawn_point : SpawnPoint = $Platform/SpawnPoint

	if can_spawn_items:
		spawn_point.spawn_chance = item_spawn_chance
		spawn_point.tag_to_load = item_type_to_load
	else:
		spawn_point.queue_free()

func get_item_spawn_point() -> SpawnPoint:
	return $Platform/SpawnPoint as SpawnPoint
