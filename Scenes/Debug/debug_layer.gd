extends CanvasLayer

func _process(delta: float) -> void:
	var frames = Engine.get_frames_per_second()
	$frames.text = "frames: %s" %str(frames)
