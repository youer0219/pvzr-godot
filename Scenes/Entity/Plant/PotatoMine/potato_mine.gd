extends Plant


@export var active_time:float = 10.0
@export var time_fator:float = 1.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


@export var is_active:bool:set = set_is_active

func _ready() -> void:
	is_active 

func set_is_active(value:bool):
	var is_same:bool = true if value == is_active else false
	is_active = value
	if !is_node_ready():
		await ready
	if !is_same:
		if is_active:
			animated_sprite_2d.play("activate")
			active_animation(-6)
		else:
			animated_sprite_2d.play("default")
			active_animation(6)


func active_animation(distance:float):
	var tween:Tween = create_tween().bind_node(self).set_ease(Tween.EASE_OUT)
	var curr_pos_y = animated_sprite_2d.position.y
	tween.tween_property(animated_sprite_2d,"position:y",curr_pos_y + distance,0.5)
