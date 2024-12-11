extends Node2D
class_name BaseGrid

const black_frame = preload("res://Scenes/Func/GridSystem/Grids/assets/不适宜种植.png")
const yellow_frame = preload("res://Scenes/Func/GridSystem/Grids/assets/适宜开炮.png")
const green_frame = preload("res://Scenes/Func/GridSystem/Grids/assets/适宜种植.png")
const red_frame = preload("res://Scenes/Func/GridSystem/Grids/assets/适宜铲除.png")

@onready var up_left_frame: Sprite2D = $UpLeftFrame
@onready var up_right_frame: Sprite2D = $UpRightFrame
@onready var down_right_frame: Sprite2D = $DownRightFrame
@onready var down_left_frame: Sprite2D = $DownLeftFrame
@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum ColorType {BLACK,YELLOW,GREEN,RED}
@export var color_type:ColorType:set = set_color_type

# 三种动画：无、强调-->消散
@export var is_highlight:bool = false:set = set_is_highlight

func _ready() -> void:
	#color_type = ColorType.YELLOW
	#await get_tree().create_timer(5).timeout
	#color_type = ColorType.GREEN
	#await get_tree().create_timer(5).timeout
	#color_type = ColorType.RED
	pass

# 消散函数

func set_is_highlight(value:bool):
	is_highlight = value
	if !is_node_ready():
		await ready
	if is_highlight:
		animation_player.play("highlight")
	else:
		animation_player.play("RESET")

func set_glo_pos(glo_pos:Vector2):
	global_position = glo_pos

func set_color_type(value:ColorType):
	color_type = value
	if !is_node_ready():
		await ready
	match color_type:
		ColorType.BLACK:
			set_image(black_frame)
		ColorType.YELLOW:
			set_image(yellow_frame)
		ColorType.GREEN:
			set_image(green_frame)
		ColorType.RED:
			set_image(red_frame)

func set_image(image):
	up_left_frame.texture = image
	up_right_frame.texture = image
	down_left_frame.texture = image
	down_right_frame.texture = image
