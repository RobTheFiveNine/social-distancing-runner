extends Node

export (int) var items_available = 0
export (int) var items_collected = 0

export (int) var covidiots_generated = 0
export (int) var covidiots_defeated = 0

export (int) var time_remaining = 0
export (int) var coin_value_collected = 0

export (bool) var died = false
export (int) var score = 0

export (int) var difficulty = 1

func recalculate_score():
	score = (Globals.covidiots_defeated * 10) * (Globals.covidiots_defeated / float(Globals.covidiots_generated))
	score += (Globals.items_collected * 5) * (Globals.items_collected / float(Globals.items_available))
	score += Globals.time_remaining + Globals.coin_value_collected
	score = score * (difficulty + 1)

func reset_stats():
	items_available = 0
	items_collected = 0
	covidiots_defeated = 0
	covidiots_generated = 0
	time_remaining = 0
	coin_value_collected = 0
	died = false
	score = 0
