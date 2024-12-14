extends Bullet

 
func _ready() -> void:
	super()
	if bullet_move is BulletTrackingMove:
		bullet_move.curr_body = self
		#bullet_move.target_body = get_tree().get_first_node_in_group("Dave")
		bullet_move.target_body = get_tree().get_first_node_in_group("Zoom")
