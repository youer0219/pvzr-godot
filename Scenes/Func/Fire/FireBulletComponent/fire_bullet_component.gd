extends Marker2D
class_name FireBulletComponent



@onready var bullets:Node2D


const BULLET = preload("res://Scenes/Entity/Bullet/bullet.tscn")

func _ready() -> void:
	bullets = get_tree().get_first_node_in_group("Bullets")

func fire():
	var bullet = BULLET.instantiate()
	bullet.global_position = global_position
	bullets.add_child(bullet)
