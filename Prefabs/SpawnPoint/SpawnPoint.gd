extends Node2D

class_name SpawnPoint

export (bool) var guaranteed_spawn = false
export (float, 0, 1) var spawn_chance = 0.3
export (String) var tag_to_load = null

func roll_spawn():
	var should_spawn : bool = guaranteed_spawn

	if not should_spawn:
		should_spawn = rand_range(0, 1) <= spawn_chance

	return should_spawn

func roll_tag(tags : Array):
	if tag_to_load:
		return tag_to_load

	return tags[int(floor(rand_range(0, len(tags))))]
