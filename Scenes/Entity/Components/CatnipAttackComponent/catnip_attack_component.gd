extends Node2D


var attack_tween:Tween
@onready var cat_tail: Sprite2D = $catTail
@onready var fire_bullet_component: FireBulletComponent = $FireBulletComponent

@export var attack_gap_time:float = 3

func _ready() -> void:
	attack_tween = create_tween().set_loops().bind_node(self)
	attack_tween.tween_property(cat_tail,"rotation_degrees",25,0.1)
	attack_tween.tween_callback(fire)
	attack_tween.tween_property(cat_tail,"rotation_degrees",0,0.1)
	attack_tween.tween_interval(attack_gap_time)


func fire():
	fire_bullet_component.fire(1)
