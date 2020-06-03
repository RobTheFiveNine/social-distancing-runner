extends AudioStreamPlayer

func play(from=0.0):
	if !playing:
		.play(from)
	else:
		var p : AudioStreamPlayer = self.duplicate(DUPLICATE_USE_INSTANCING)
		get_parent().add_child(p)
		p.stream = stream
		p.play()
		yield(p, "finished")
		p.queue_free()
