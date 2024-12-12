extends Sprite2D
class_name BlinkSpriteComponent

var blink_tween:Tween
@export_range(0,1) var end_blink_intensity:float = 0.95
@export var bline_time:float = 0.4
@export var blink_all_time:float = 0.6
@export var gap_time:float = 2

func _ready() -> void:
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

func apply_effect():
	
	pass
