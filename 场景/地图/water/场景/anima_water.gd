class_name AnimaWater
extends Node2D

@onready var image: AnimatedSprite2D = %Image
@export var gap_time:float = 1.0
@export var move_distance:float = 8

func _ready() -> void:
	image.frame = randi_range(0,31)


func start_float():
	var tween = get_tree().create_tween()
	tween.tween_property(image,"global_position",self.global_position + Vector2(0,move_distance),gap_time).set_trans(Tween.TRANS_SINE)
	tween.tween_property(image,"global_position",self.global_position     ,gap_time).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(start_float)
