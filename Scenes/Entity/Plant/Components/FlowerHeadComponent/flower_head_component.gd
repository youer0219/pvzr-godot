extends Node2D



func _ready() -> void:
	var tween = get_tree().create_tween().set_loops().bind_node(self)
	tween.tween_method(SetShader_BlinkIntensity,0.0,0.85,0.5)
	tween.tween_interval(0.5)

func SetShader_BlinkIntensity(new_value:float):
	material.set_shader_parameter("blink_intensity",new_value)
