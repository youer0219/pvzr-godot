extends CanvasLayer

@onready var mask_color: ColorRect = $MaskColor

@export var gap_time:float = 0.25
@export var is_runing:bool = false : set = set_is_runing

var light_tween:Tween

func _ready() -> void:
	light_tween = get_tree().create_tween().set_loops().bind_node(self)
	light()
	light_tween.stop()

func light():
	light_tween.tween_interval(gap_time * 3)
	light_tween.tween_callback(init_mask_color)
	light_tween.tween_property(mask_color,"color",Color(0,0,0,1),gap_time)
	light_tween.tween_interval(gap_time)
	light_tween.tween_callback(light_mask_color)
	light_tween.tween_property(mask_color,"color",Color(1,1,1,0),gap_time)

func init_mask_color():
	mask_color.color = Color(0,0,0,0)

func light_mask_color():
	mask_color.color = Color(1,1,1,0.5)

func set_is_runing(value:bool):
	is_runing = value
	if !is_node_ready():
		await ready
	if is_runing:
		self.visible = true
		light_tween.play()
	else:
		self.visible = false
		light_tween.stop()
