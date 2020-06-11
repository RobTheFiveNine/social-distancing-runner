extends Node2D

signal entered_end_zone()
signal ready_to_finish()

export (int) var speed = 300
export (Vector2) var boat_destination = Vector2()

onready var player : AnimationPlayer = $AnimationPlayer
onready var boat : KinematicBody2D = $Boat

var boat_moving : bool = false

func _physics_process(delta):
	if boat_moving:
		boat.move_local_x(speed * delta)

		if boat.position.x > boat_destination.x:
			emit_signal("ready_to_finish")

func _on_Area2D_body_entered(body : Player):
	boat_moving = true
	body.prevent_jumping = true
	emit_signal("entered_end_zone")

