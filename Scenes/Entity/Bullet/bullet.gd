extends Node2D
class_name Bullet

@export var bullet_move:BulletMove
@onready var hitbox: Hitbox = $Hitbox

enum Direction {RIGHT,LEFT}
var direction:Direction = Direction.RIGHT:set = set_direction

func _ready() -> void:
	hitbox.hit_target.connect(hit_target)
	await get_tree().create_timer(10.0).timeout
	queue_free()

func set_direction(value):
	direction = value
	if !is_node_ready():
		await ready
	bullet_move.direction = direction

func hit_target():
	queue_free()
