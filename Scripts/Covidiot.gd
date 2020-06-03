extends KinematicBody2D

class_name Covidiot

signal found_player(enemy)

export (int) var variation = 0
export (int) var speed = 100
export (bool) var pursuit = false

var velocity : Vector2
var animation_player : AnimationPlayer
var player_path : String

func _ready():	
	velocity = Vector2()
	animation_player = get_node("AnimationPlayer")
	animation_player.play("Neutral")

func _physics_process(delta):
	velocity.y = 900
	
	if pursuit:
		var player : KinematicBody2D = get_node(player_path)
		velocity.x = position.direction_to(player.position).x * speed
		
	if velocity.x != 0:
		if velocity.x < 0:
			animation_player.play("Walk_Left")
		else:
			animation_player.play("Walk_Right")
		
	move_and_slide(velocity)

func die():
	queue_free()

func _on_Area2D_body_entered(body):
	emit_signal("found_player", self)
