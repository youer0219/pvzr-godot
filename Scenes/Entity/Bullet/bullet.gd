extends Node2D
class_name Bullet

enum Direction {RIGHT,LEFT}

signal change_direction(direction:Bullet.Direction)

func _ready() -> void:
	await get_tree().create_timer(10.0).timeout
	queue_free()

func set_direction(direction:Bullet.Direction):
	change_direction.emit(direction)
