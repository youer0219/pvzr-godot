extends Sprite2D
class_name VisualSpriteComponent

## 目前提供了'发光'和'顶部摇摆'的视觉效果

@export var sway_strength:float = 2.0:set = set_sway_strength
@export var sway_speed:float = 3.0:set = set_sway_speed

var blink_tween:Tween
@export_range(0,1) var end_blink_intensity:float = 1.0
@export var bline_time:float = 0.15
@export var blink_all_time:float = 0.4
@export var blink_fade_time:float = 0.25
@export var gap_time:float = 2
@export var is_blinking:bool = false:set = set_is_blinking
var visual_material:ShaderMaterial


func _ready() -> void:
	visual_material = material
	ready_blink()

#region ZOOM部分
func zoom_under_attack_blink():
	var zoom_tween:Tween = create_tween().bind_node(self)
	zoom_tween.tween_method(set_blink_intensity,0,0.55,0.1)
	zoom_tween.tween_method(set_blink_intensity,0.55,0,0.2)

#endregion
#region CornCannon Blink部分
var cannon_ball_tween:Tween
func cannon_ball_blink():
	cannon_ball_tween = create_tween().set_loops().bind_node(self)
	cannon_ball_tween.tween_method(set_blink_intensity,0,1,0.15)
	cannon_ball_tween.tween_method(set_blink_intensity,1,0,0.15)
	cannon_ball_tween.tween_interval(0.3)

#endregion
#region Flower Blink部分
func ready_blink():
	blink_tween = get_tree().create_tween().set_loops().bind_node(self)
	blink_tween.stop()
	is_blinking=false
	set_bilnk_tween()

func set_bilnk_tween():
	blink_tween.tween_method(set_blink_intensity,0.0,end_blink_intensity,bline_time)
	blink_tween.tween_interval(blink_all_time)
	blink_tween.tween_method(set_blink_intensity,end_blink_intensity,0,blink_fade_time)
	blink_tween.tween_interval(gap_time)

func set_blink_intensity(new_value:float):
	visual_material.set_shader_parameter("blink_intensity",new_value)

func set_blink_color(color:Color):
	visual_material.set_shader_parameter("blink_color",color)

func start_blink():
	if !blink_tween.is_running():
		blink_tween.play()

func stop_blink():
	blink_tween.stop()

func set_is_blinking(value:bool):
	is_blinking = value
	if !is_node_ready():
		await ready
	if is_blinking:
		start_blink()
	else:
		stop_blink()
#endregion
#region sway部分
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

func set_sway_mode(is_vertical:bool):
	visual_material.set_shader_parameter("is_vertical",is_vertical)

#endregion
