extends Node2D

var listen_for_input = false

func _input(event):
	if listen_for_input and event is InputEventKey:
		get_tree().change_scene("res://Scenes/Title/Title.tscn")

func _ready():
	$CanvasLayer/MarginContainer2/Input_Notice.visible = false

	var final_score = 0
	final_score += (Globals.covidiots_defeated * 10) * (Globals.covidiots_defeated / Globals.covidiots_generated)
	final_score += (Globals.items_collected * 5) * (Globals.items_collected / Globals.items_available)
	final_score += Globals.time_remaining + Globals.coin_value_collected
	
	set_stat("Items_Collected", Globals.items_collected, Globals.items_available)
	set_stat("Covidiots_Defeated", Globals.covidiots_defeated, Globals.covidiots_generated)
	set_stat("Time_Bonus", Globals.time_remaining)
	set_stat("Coin_Bonus", Globals.coin_value_collected)
	set_stat("MarginContainer2/Final_Score", final_score)
	
	if Globals.died:
		$CanvasLayer/MarginContainer3/Game_Over_Title.text = "GAME OVER"
	else:
		$CanvasLayer/MarginContainer3/Game_Over_Title.text = "SCOREBOARD"
	
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

func _on_Transition_unblanked(tag):
	listen_for_input = true
	$CanvasLayer/MarginContainer2/Input_Notice.visible = true
