extends Marker2D




@onready var bullets:Node2D

const BULLET = preload("res://Scenes/Entity/Bullet/bullet.tscn")

func _ready() -> void:
	bullets = get_tree().get_first_node_in_group("Bullets")
	var tween = get_tree().create_tween().set_loops()
	tween.tween_callback(fire).set_delay(2.0)



func fire():
	var bullet = BULLET.instantiate()
	bullet.global_position = global_position
	bullets.add_child(bullet)
