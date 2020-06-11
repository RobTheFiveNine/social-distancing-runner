extends Node2D

var listen_for_input = false

func _input(event):
	if listen_for_input and event is InputEventKey:
		get_tree().change_scene("res://Scenes/Title/Title.tscn")

func _ready():
	Globals.recalculate_score()
	$CanvasLayer/MarginContainer2/Input_Notice.visible = false

	set_stat("Items_Collected", Globals.items_collected, Globals.items_available)
	set_stat("Covidiots_Defeated", Globals.covidiots_defeated, Globals.covidiots_generated)
	set_stat("Time_Bonus", Globals.time_remaining)
	set_stat("Coin_Bonus", Globals.coin_value_collected)
	set_stat("MarginContainer2/Final_Score", Globals.score)
	
	if Globals.died:
		$CanvasLayer/MarginContainer3/Game_Over_Title.text = "GAME OVER"
	else:
		$CanvasLayer/MarginContainer3/Game_Over_Title.text = "YOU ESCAPED!"
	
	$AnimationPlayer.play("Wait_Input")
	$CanvasLayer/Control/Transition.unblank()

func set_stat(name, value, total = null):
	if total != null:
		get_node("CanvasLayer/MarginContainer/GridContainer/%s" % name).text = (
			"%d/%d" % [value, total]
		)
	else:
		get_node("CanvasLayer/MarginContainer/GridContainer/%s" % name).text = (
			"%d" % value
		)

func _on_Transition_unblanked(_tag):
	listen_for_input = true
	$CanvasLayer/MarginContainer2/Input_Notice.visible = true
