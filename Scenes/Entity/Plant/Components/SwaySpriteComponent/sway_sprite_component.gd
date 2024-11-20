extends Sprite2D
class_name SwaySpriteComponent

@export var sway_strength:float = 2.0:set = set_sway_strength
@export var sway_speed:float = 3.0:set = set_sway_speed

var sway_material:ShaderMaterial

func _ready() -> void:
	sway_material = material

func set_sway_shader():
	sway_material.set_shader_parameter("strength",sway_strength)
	sway_material.set_shader_parameter("speed",sway_speed)

func set_sway_strength(value:float):
	sway_strength = value
	set_sway_shader()

func set_sway_speed(value:float):
	sway_speed = value
	set_sway_shader()
