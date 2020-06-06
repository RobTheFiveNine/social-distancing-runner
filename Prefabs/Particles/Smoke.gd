extends CPUParticles2D

func restart():
	.restart()
	get_node("AudioStreamPlayer2D").play()
