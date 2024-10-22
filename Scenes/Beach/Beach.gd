extends Node2D

export (String) var game_over_scene_path = "res://Scenes/Game_Over/Game_Over.tscn"

var last_encounter_won = false
var started = false

onready var smoke : CPUParticles2D = $Smoke
onready var time_label : Label = $CanvasLayer/MarginContainer/GridContainer/TimeLabel
onready var score_label : Label = $CanvasLayer/MarginContainer/GridContainer/ScoreLabel
onready var timer : Timer = $Timer
onready var transition : Transition = $CanvasLayer/Transition
onready var player : Player = $Player
onready var item_audio : AudioStreamPlayer = $ItemAudioPlayer

const ENEMY_TYPES = {
	c1v1 = preload("res://Prefabs/Characters/Covidiot_1/Covidiot_1.tscn"),
	c1v2 = preload("res://Prefabs/Characters/Covidiot_1/Covidiot_1.tscn"),
	c2 = preload("res://Prefabs/Characters/Covidiot_2/Covidiot_2.tscn")
}

const ITEM = preload("res://Prefabs/Item/Item.tscn")
const ITEM_TYPES = ["energy", "time", "heart", "coin"]

func redraw_hp_icons():
	for i in range(1, 4):
		var icon = get_node(
			"CanvasLayer/MarginContainer/GridContainer/HBoxContainer/HP%d" % i
		)

		if player.health < i:
			icon.modulate = Color(1, 1, 1, 0.23)
		else:
			icon.modulate = Color(1, 1, 1, 1)

func end_game(pause_before_transition : bool = true):
	timer.paused = true

	if not Globals.died:
		Globals.time_remaining = timer.time_left

	var audio = $AudioStreamPlayer
	
	var audio_tween = Tween.new()
	add_child(audio_tween)
	audio_tween.interpolate_property(
		audio, "volume_db",
		audio.volume_db, -50, 1.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN
	)

	if pause_before_transition:
		yield(get_tree().create_timer(2.0), "timeout")
	
	transition.blank({
		next_scene = "game_over"
	})

	audio_tween.start()
	
	yield(transition, "blanked")
	return get_tree().change_scene(game_over_scene_path)

func generate_item(spawn_point : SpawnPoint) -> void:
	if spawn_point.roll_spawn():
		var tag = spawn_point.roll_tag(ITEM_TYPES)
		var item = ITEM.instance()

		item.set_type(tag)
		item.position = spawn_point.position
		item.connect("picked_up", self, "_on_item_picked_up")
		
		Globals.items_available += 1
		spawn_point.get_parent().add_child(item)

	spawn_point.queue_free()

func generate_items() -> void:
	for spawn_point in $Item_Spawn_Points.get_children():
		generate_item(spawn_point)

	for platform in $MovingPlatforms.get_children():
		if platform.can_spawn_items:
			generate_item(platform.get_item_spawn_point())

	pass

func generate_covidiots() -> void:
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

func spawn_smoke(at_location):
	smoke.position = Vector2(
		at_location.x + 5.584,
		at_location.y + 125.78
	)

	smoke.restart()

func start_game():
	timer.start()
	player.ignore_input = false
	started = true

func _ready():
	randomize()

	Globals.reset_stats()

	player.ignore_input = true
	transition.visible = true

	generate_covidiots()
	generate_items()

	transition.unblank()
	
	$AudioStreamPlayer.play()
	
func _process(_delta):
	if started:
		time_label.text = "TIME\n%.2f" % timer.time_left
	else:
		time_label.text = "TIME\n%.2f" % timer.wait_time

	score_label.text = "SCORE\n%d" % Globals.score

func _on_encounter_finished(won):
	last_encounter_won = won

	if won:
		Globals.covidiots_defeated += 1
		Globals.recalculate_score()

	transition.blank({
		next_scene = "beach"
	})

func _on_transition_unblanked(tag):
	if !tag:
		return $CanvasLayer/Countdown.start()

	if tag.next_scene == "beach":
		get_tree().paused = false
		player.process_encounter_result(last_encounter_won)		

func _on_transition_blanked(tag):
	if tag.next_scene == "beach":
		get_node("CanvasLayer/Encounter").visible = false
		get_node("CanvasLayer/MarginContainer").visible = true
		transition.unblank()
	elif tag.next_scene == "encounter":
		get_node("CanvasLayer/MarginContainer").visible = false

func _on_enemy_died(death_location):
	spawn_smoke(death_location)

func _on_Timer_timeout():
	player.die()

func _on_Player_hit(remaining_health, player_position):
	redraw_hp_icons()

	if remaining_health == 0:
		Globals.died = true
		spawn_smoke(player_position)
		end_game()

func _on_time_picked_up() -> void:
	var new_time = timer.time_left + 20
	timer.stop()
	timer.wait_time = new_time
	timer.start()

func _on_energy_picked_up() -> void:
	player.use_energy_boost()

func _on_heart_picked_up() -> void:
	if player.health < 3:
		player.health += 1

	redraw_hp_icons()

func _on_coin_picked_up() -> void:
	Globals.coin_value_collected += 10

func _on_item_picked_up(item : Item) -> void:
	var item_type = item.get_type()
	
	if item_type == "time":
		_on_time_picked_up()
	elif item_type == "energy":
		_on_energy_picked_up()
	elif item_type == "heart":
		_on_heart_picked_up()
	elif item_type == "coin":
		_on_coin_picked_up()

	Globals.items_collected += 1
	Globals.recalculate_score()
	item_audio.play()
	item.queue_free()

func _on_EndZone_entered_end_zone():
	timer.paused = true

func _on_EndZone_ready_to_finish():
	end_game(false)
