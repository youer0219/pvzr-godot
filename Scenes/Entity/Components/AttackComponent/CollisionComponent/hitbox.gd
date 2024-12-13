extends Area2D
class_name Hitbox

var damage:int = 1
signal hit_target
func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		area.take_damage(damage)
	hit_target.emit()

#TODO: 将这个改成多选.不然以后就需要多个组件一起工作。
enum Type {PLANT=64,ZOOM=16,DAVE=32}
@export var type:Type = Type.PLANT

var _type:Type:set = set_type
func _ready() -> void:
	_type = type

func set_type(value:Type):
	type = value
	set_box_mask_layer(type)

func set_box_mask_layer(layer:int):
	collision_mask = layer
