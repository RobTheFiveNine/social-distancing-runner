extends ParallaxLayer


func _ready():	
	for c in get_children():
		c.set_scale(Vector2(0.8, 0.8))
		c.set_position(Vector2(c.position.x - 300, c.position.y - 185))
