extends Marker2D
class_name FireBulletComponent



@onready var bullets:Node2D

@export var bullet_scene:PackedScene

func _ready() -> void:
	bullets = get_tree().get_first_node_in_group("Bullets")

func fire(direction:Bullet.Direction):
	var bullet:Bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = direction
	bullets.add_child(bullet)
