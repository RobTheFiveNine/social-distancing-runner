extends KinematicBody2D

class_name Covidiot

signal found_player(enemy)


var velocity : Vector2


# Called when the node enters the scene tree for the first time.
func _ready():	
	velocity = Vector2()
	pass # Replace with function body.


func _physics_process(delta):
	velocity.y = 900
	move_and_slide(velocity)

func die():
	get_parent().remove_child(self)

func _on_Area2D_body_entered(body):
	print("body entered")
	emit_signal("found_player", self)
