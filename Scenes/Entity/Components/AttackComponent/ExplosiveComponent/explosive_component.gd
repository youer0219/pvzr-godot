extends Node2D
class_name ExplosiveComponent

@export var explosive_effect:PackedScene



func get_explosive_effect_scene()->Node2D:
	var new_effect:Node2D = explosive_effect.instantiate()
	new_effect.global_position = global_position
	return new_effect
