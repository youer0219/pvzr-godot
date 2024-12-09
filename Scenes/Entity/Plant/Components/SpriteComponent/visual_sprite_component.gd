extends Sprite2D
class_name VisualSpriteComponent

## 目前提供了'发光'和'顶部摇摆'的视觉效果

@export var sway_strength:float = 2.0:set = set_sway_strength
@export var sway_speed:float = 3.0:set = set_sway_speed

var blink_tween:Tween
@export_range(0,1) var end_blink_intensity:float = 0.95
@export var bline_time:float = 0.4
@export var blink_all_time:float = 0.6
@export var gap_time:float = 2
var visual_material:ShaderMaterial

func _ready() -> void:
	visual_material = material
	set_bilnk_tween()


func set_bilnk_tween():
	blink_tween = get_tree().create_tween().set_loops().bind_node(self)
	blink_tween.tween_method(SetShader_BlinkIntensity,0.0,end_blink_intensity,bline_time)
	blink_tween.tween_interval(blink_all_time)
	blink_tween.tween_callback(
		func():
			material.set_shader_parameter("blink_intensity",0)
			)
	blink_tween.tween_interval(gap_time)

func SetShader_BlinkIntensity(new_value:float):
	material.set_shader_parameter("blink_intensity",new_value)

func set_sway_shader():
	visual_material.set_shader_parameter("strength",sway_strength)
	visual_material.set_shader_parameter("speed",sway_speed)

func set_sway_strength(value:float):
	sway_strength = value
	if !is_node_ready():
		await ready
	set_sway_shader()

func set_sway_speed(value:float):
	sway_speed = value
	if !is_node_ready():
		await ready
	set_sway_shader()
