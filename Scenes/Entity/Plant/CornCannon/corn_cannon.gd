extends Plant


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Cannonball.set_blink_color(Color.ALICE_BLUE)
	$Cannonball.cannon_ball_blink()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
