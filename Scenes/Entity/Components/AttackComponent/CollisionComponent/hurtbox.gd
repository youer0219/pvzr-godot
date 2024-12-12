extends Area2D
class_name Hurtbox

enum Type {PLANT=64,ZOOM=16,DAVE=32}

@export var type:Type = Type.PLANT
var _type:Type:set = set_type

func set_type(value:Type):
	type = value
	set_box_layer(type)

func set_box_layer(layer:int):
	collision_layer = layer

signal under_damage

func _ready() -> void:
	_type = type

func take_damage(damage:int):
	#print(owner.name," under attack :",damage)
	under_damage.emit()
