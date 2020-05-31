extends Node


var next_scene : String

# Called when the node enters the scene tree for the first time.
func _ready():
	print('globals ready')
	pass # Replace with function body.

func _process(delta):
	if next_scene != "":
		print(next_scene)
		
func set_next_scene(value):
	print("globals::set_next_scene")
	next_scene = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
