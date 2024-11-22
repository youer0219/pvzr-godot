extends BulletMove



func _physics_process(delta: float) -> void:
	owner.position.x += direction * speed * delta
