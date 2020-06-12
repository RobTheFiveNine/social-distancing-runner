extends Node2D

signal game_starting()

onready var easy_coin : Sprite = $EasyCoin
onready var medium_coin : Sprite = $MediumCoin
onready var hard_coin : Sprite = $HardCoin
onready var instructions_container : MarginContainer = $CanvasLayer/InstructionsContainer
onready var difficulty_container : MarginContainer = $CanvasLayer/DifficultyContainer

var selecting_difficulty : bool = false
var difficulty = 1

func _ready():
	instructions_container.visible = true
	difficulty_container.visible = false

	easy_coin.visible = false
	medium_coin.visible = false
	hard_coin.visible = false

	$AnimationPlayer.play("Flash")

func _input(event : InputEvent):
	if not event is InputEventKey:
		return

	if !event.is_pressed() or event.is_echo():
		return

	if not selecting_difficulty:
		selecting_difficulty = true
		instructions_container.visible = false
		difficulty_container.visible = true
		medium_coin.visible = true
		return

	if Input.is_action_just_pressed("ui_select"):
		Globals.difficulty = difficulty
		emit_signal("game_starting")
	elif Input.is_action_just_pressed("ui_down"):
		difficulty = int(min(difficulty + 1, 2))
	elif Input.is_action_just_pressed("ui_up"):
		difficulty = int(max(difficulty - 1, 0))

	if difficulty == 0:
		easy_coin.visible = true
		medium_coin.visible = false
	elif difficulty == 1:
		easy_coin.visible = false
		medium_coin.visible = true
		hard_coin.visible = false
	elif difficulty == 2:
		medium_coin.visible = false
		hard_coin.visible = true

func _on_Transition_blanked(_tag):
	get_tree().change_scene("res://Scenes/Beach/Beach.tscn")
