class_name AnimaWater
extends Node2D

@onready var image: AnimatedSprite2D = %Image
@export var gap_time:float = 0.8
@export var move_distance:float = 8

var is_top:bool = false:
	set(value):
		is_top = value
		if is_top:
			start_float()

func _ready() -> void:
	image.frame = randi_range(0,31)


func start_float():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(image,"global_position:y",self.global_position.y + move_distance,gap_time).set_trans(Tween.TRANS_SINE)
	tween.tween_property(image,"global_position:y",self.global_position.y     ,gap_time).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(start_float)
