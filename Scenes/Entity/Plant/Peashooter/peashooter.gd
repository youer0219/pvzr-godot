extends Node2D


@export var bullet_direction:Bullet.Direction: set = set_bullet_direction

signal change_direction(direction:Bullet.Direction)

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	bullet_direction = Bullet.Direction.RIGHT
	await get_tree().create_timer(5).timeout
	bullet_direction = Bullet.Direction.LEFT

func set_bullet_direction(value):
	bullet_direction = value
	if !is_node_ready():
		await ready
	if bullet_direction == Bullet.Direction.LEFT:
		self.scale.x = -1
	else:
		self.scale.x = 1
	change_direction.emit(bullet_direction)
