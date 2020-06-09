extends Node2D

class_name Item

var item_type : String
var energy_texture = preload("res://Sprites/Items/Energy.128px.png")
var heart_texture = preload("res://Sprites/Items/Heart.10pc.png")
var coin_texture = preload("res://Sprites/Items/Coin.128px.png")
var time_texture = preload("res://Sprites/Items/Stopwatch.128px.png")

signal picked_up(item)

func _ready():
	$AnimationPlayer.play("Float")

func set_type(new_type : String):
	if new_type == "energy":
		$Sprite.texture = energy_texture
		$Sprite.rotate(deg2rad(-45))
	elif new_type == "time":
		$Sprite.texture = time_texture
	elif new_type == "heart":
		$Sprite.texture = heart_texture
	elif new_type == "coin":
		$Sprite.texture = coin_texture

	item_type = new_type

func get_type() -> String:
	return item_type

func _on_Area2D_body_entered(_body):
	emit_signal("picked_up", self)
