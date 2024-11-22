extends Node2D
class_name Bullet

@export var bullet_move:BulletMove

enum Direction {RIGHT,LEFT}
var direction:Direction = Direction.RIGHT:set = set_direction

func _ready() -> void:
	await get_tree().create_timer(10.0).timeout
	queue_free()

func set_direction(value):
	direction = value
	if !is_node_ready():
		await ready
	bullet_move.direction = direction
