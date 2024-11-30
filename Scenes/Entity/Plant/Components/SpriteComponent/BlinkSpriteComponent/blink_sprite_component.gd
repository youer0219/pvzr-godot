extends Sprite2D
class_name BlinkSpriteComponent

var blink_tween:Tween
@export_range(0,1) var end_blink_intensity:float = 0.85
@export var bline_time:float = 0.5
@export var gap_time:float = 5

func _ready() -> void:
	blink_tween = get_tree().create_tween().set_loops().bind_node(self)
	blink_tween.tween_method(SetShader_BlinkIntensity,0.0,end_blink_intensity,bline_time)
	blink_tween.tween_interval(gap_time)


func SetShader_BlinkIntensity(new_value:float):
	material.set_shader_parameter("blink_intensity",new_value)

func apply_effect():
	
	pass
