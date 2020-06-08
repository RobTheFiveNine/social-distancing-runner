extends Node2D

export (String) var game_over_scene_path = "res://Scenes/Game_Over/Game_Over.tscn"

var last_encounter_won = false
var smoke : CPUParticles2D
var time_label : Label
var score_label : Label
var timer : Timer
var transition : Transition
var player : Player
var item_audio : AudioStreamPlayer

const ENEMY_TYPES = {
	c1v1 = preload("res://Prefabs/Characters/Covidiot_1/Covidiot_1.tscn"),
	c1v2 = preload("res://Prefabs/Characters/Covidiot_1/Covidiot_1.tscn"),
	c2 = preload("res://Prefabs/Characters/Covidiot_2/Covidiot_2.tscn")
}

const ITEM = preload("res://Prefabs/Item/Item.tscn")
const ITEM_TYPES = ["energy", "time", "heart", "coin"]

func draw_remaining_hp(hp):
	for i in range(hp + 1, 4):
		get_node(
			"CanvasLayer/MarginContainer/GridContainer/HBoxContainer/HP%d" % i
		).modulate = Color(1, 1, 1, 0.23)

func end_game():
	$Timer.paused = true
	yield(get_tree().create_timer(2.0), "timeout")
	
	transition.blank({
		next_scene = "game_over"
	})
	
	yield(transition, "blanked")
	return get_tree().change_scene(game_over_scene_path)

func generate_items():
	var spawns = $Item_Spawn_Points
	for s in spawns.get_children():
		if not s.roll_spawn():
			continue

		var tag = s.roll_tag(ITEM_TYPES)
		var item = ITEM.instance()

		item.set_type(tag)
		item.position = s.position
		item.connect("picked_up", self, "_on_item_picked_up")
		
		Globals.items_available += 1
		add_child(item)


	spawns.queue_free()

func generate_covidiots():
	var spawns = $Enemy_Spawn_Points
	for s in spawns.get_children():
		if not s.roll_spawn():
			continue

		var tag = s.roll_tag(ENEMY_TYPES.keys())
		var c = ENEMY_TYPES[tag].instance()
		
		c.variation = 1
		c.position = s.position
		c.player_path = player.get_path()
		c.pursuit = true
		c.speed = int(rand_range(250, 650))

		if tag == "c1v1":
			c.pursuit = false
			c.variation = 0

		c.connect("found_player", player, "_on_enemy_found_player")
		c.connect("died", self, "_on_enemy_died")
		add_child(c)

		Globals.covidiots_generated += 1

	spawns.queue_free()

func _ready():
	randomize()

	Globals.reset_stats()

	player = get_node("Player")
	get_node("CanvasLayer/Transition").visible = true
	smoke = get_node("Smoke")
	time_label = get_node("CanvasLayer/MarginContainer/GridContainer/TimeLabel")
	timer = get_node("Timer")
	transition = get_node("CanvasLayer/Transition")
	score_label = get_node("CanvasLayer/MarginContainer/GridContainer/ScoreLabel")
	item_audio = get_node("ItemAudioPlayer")

	generate_covidiots()
	generate_items()
	
	#$AudioStreamPlayer.play()
	
func _process(_delta):
	time_label.text = "TIME\n%.2f" % timer.time_left
	score_label.text = "SCORE\n%d" % Globals.score

func _on_encounter_finished(won):
	last_encounter_won = won
	transition.blank({
		next_scene = "beach"
	})

func _on_transition_unblanked(tag):
	if tag.next_scene == "beach":
		get_tree().paused = false
		get_node("Player").process_encounter_result(last_encounter_won)

func _on_transition_blanked(tag):
	if tag.next_scene == "beach":
		get_node("CanvasLayer/Encounter").visible = false
		get_node("CanvasLayer/MarginContainer").visible = true
		transition.unblank()
	elif tag.next_scene == "encounter":
		get_node("CanvasLayer/MarginContainer").visible = false

func _on_enemy_died(death_location):
	spawn_smoke(death_location)
	Globals.covidiots_defeated += 1

func spawn_smoke(at_location):
	smoke.position = Vector2(
		at_location.x + 5.584,
		at_location.y + 125.78
	)

	smoke.restart()

func _on_Timer_timeout():
	player.die()

func _on_Player_hit(remaining_health, player_position):
	if remaining_health == 0:
		Globals.died = true
		spawn_smoke(player_position)
		end_game()
	else:
		draw_remaining_hp(remaining_health)

func _on_item_picked_up(item : Item):
	Globals.items_collected += 1
	item_audio.play()
	item.queue_free()
