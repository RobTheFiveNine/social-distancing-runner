extends KinematicBody2D

class_name Covidiot

signal found_player(enemy)

export (int) var variation = 0

var velocity : Vector2
var animation_player : AnimationPlayer

func _ready():	
	velocity = Vector2()
	animation_player = get_node("AnimationPlayer")
	animation_player.play("Neutral")

func _physics_process(delta):
	velocity.y = 900
	move_and_slide(velocity)

func die():
	get_parent().remove_child(self)

func _on_Area2D_body_entered(body):
	print(body.name)
	emit_signal("found_player", self)
