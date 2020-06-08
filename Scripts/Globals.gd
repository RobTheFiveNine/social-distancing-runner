extends Node

export (int) var items_available = 1
export (int) var items_collected = 0

export (int) var covidiots_generated = 1
export (int) var covidiots_defeated = 0

export (int) var time_remaining = 0
export (int) var coin_value_collected = 0

export (bool) var died = false
export (int) var score = 0

func recalculate_score():
	score = (Globals.covidiots_defeated * 10) * (Globals.covidiots_defeated / Globals.covidiots_generated)
	score += (Globals.items_collected * 5) * (Globals.items_collected / Globals.items_available)
	score += Globals.time_remaining + Globals.coin_value_collected
