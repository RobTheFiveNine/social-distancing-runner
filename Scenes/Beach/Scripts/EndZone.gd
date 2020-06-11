extends Node2D

signal entered_end_zone()
signal ready_to_finish()

func _on_Area2D_body_entered(body : Player):
	body.ignore_input = true
	body.position = Vector2(self.position.x, self.position.y - 200)
	emit_signal("entered_end_zone")
