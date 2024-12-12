extends Area2D
class_name Hitbox

var damage:int = 1

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		area.under_attack.emit.bind(damage)


enum Type {PLANT=64,ZOOM=16,DAVE=32}

@export var type:Type = Type.PLANT:set = set_type

func set_type(value:Type):
	type = value
	set_box_mask_layer(type)

func set_box_mask_layer(layer:int):
	collision_mask = layer
