extends KinematicBody2D

class_name Covidiot

signal found_player(enemy)
signal died(death_position)

export (int) var variation = 0
export (int) var speed = 300
export (bool) var pursuit = false
export (bool) var ignore_physics = false
export (int) var limit_bottom = 2550

var velocity : Vector2
var animation_player : AnimationPlayer
var player_path : String
var pursuiting = false

func _ready():	
	velocity = Vector2()
	animation_player = get_node("AnimationPlayer")
	animation_player.play("Neutral")

func _physics_process(delta):
	if ignore_physics:
		return

	velocity.x = 0
	velocity.y = 900
	
	if pursuiting:
		var player : KinematicBody2D = get_node(player_path)
		velocity.x = position.direction_to(player.position).x * speed
		
	if velocity.x != 0:
		if velocity.x < 0:
			animation_player.play("Walk_Left")
		else:
			animation_player.play("Walk_Right")
	else:
		animation_player.play("Neutral")
		
	move_and_slide(velocity)
	
	if position.y >= limit_bottom:
		die()

func die():
	emit_signal("died", position)
	queue_free()

func _on_Area2D_body_entered(body):
	emit_signal("found_player", self)

func _on_LineOfSightArea_body_entered(body):
	if pursuit:
		pursuiting = true
	
func _on_LineOfSightArea_body_exited(body):
	pursuiting = false
