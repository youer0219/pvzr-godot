extends Node2D
class_name Move

@onready var wall_right_down_check: RayCast2D = %WallRightDownCheck
@onready var wall_right_up_check: RayCast2D = %WallRightUpCheck
@onready var wall_left_down_check: RayCast2D = %WallLeftDownCheck
@onready var wall_left_up_check: RayCast2D = %WallLeftUpCheck
@onready var ladder_check: RayCast2D = %LadderCheck
@onready var water_check: RayCast2D = %WaterCheck
@onready var lateral_movement_timer: Timer = %LateralMovementTimer

const MAX_FALL_VELOCITY := 200

enum LengthwiseMoveType {CLAMP,JUMP,NULL}

## 移动实体
@export var char_body:CharacterBody2D
@export var can_move:bool = true
var water_layer:WaterLayer
var top_water:AnimaWater
var char_velocity:Vector2
var char_rotation_degrees:float
var char_face_dir:int = 1


@export_group("LateralMove")
## 横向移动最大速度
@export var lateral_speed:float = 90
## 横向移动加速度
@export var lateral_speed_acceleration:float = 100
## 横向移动小小跳
@export var lateral_small_jump:float = 30
## 横向移动小跳
@export var lateral_common_jump:float = 70
@export_range(0.05,0.18) var lateral_input_gap_time:float = 0.15
var lateral_input_max_time:float = 0.2
var is_lateral_moving:bool
@export_subgroup("Deflexion")
## 偏转角度
@export var move_rotation_degrees:int = 10
## 偏转改变速度
@export var rotation_change_speed:float = 40
## 旋转一圈的时间
@export var turn_time:float = 0.3

@export_group("LengthwiseMove")
## 下落速度
@export var length_down_speed:float = 280
@export_subgroup("Jump")
## 可跳跃次数
@export var jump_times:int = 2
@export var jump_lateral_move:float = 120
var current_jump_times:int = jump_times
## 跳跃速度
@export var jump_velocity:float = 120
@export_subgroup("Clamp")
## 攀爬速度
@export var clamp_velocity:float = 50
var is_clamping:bool
var can_clamp:bool = true:
	get:
		return can_clamp if !is_on_floor() else true

@export_group("Water")
## 在水中的下落速度
@export var water_init_speed:float = 10
@export var water_down_speed:float = 65
@export var water_up_speed:float = 30
## 图像中心点偏移量
@export var water_sprite_offect_distance:float = -4
var is_sink_in_water:bool


func _ready() -> void:
	water_layer = get_tree().get_first_node_in_group("water_layer")

func _physics_process(delta: float) -> void:
	move_by_input(delta)

func move_by_input(delta:float):
	if can_move:
		char_velocity = char_body.velocity
		char_rotation_degrees = char_body.rotation_degrees
		
		move_dir_control(delta)
		
		var lateral_direction := Input.get_axis("move_left", "move_right")
		lateral_move(lateral_direction,delta)
		
		var lengthwise_move_type:LengthwiseMoveType = get_lengthwise_move_type_by_input()
		lengthwise_move(lengthwise_move_type,delta)
		
		update_state_by_water()
		move_deflexion_control(delta)
		apply_gravity(delta)
		char_body.velocity = char_velocity
		char_body.rotation_degrees = char_rotation_degrees
		char_body.move_and_slide()

#region 横移移动 

func lateral_move(lateral_direction:int,delta:float):
	if lateral_direction:
		# 水的影响
		var water_move_foctor = 0.75 if is_in_water() else 1.0
		# 如果刚刚开始，就开始计时，并小跳小移动
		if !is_lateral_moving:
			lateral_movement_timer.start(lateral_input_max_time)
			is_lateral_moving = true
			lateral_jump(lateral_small_jump)
			char_velocity.x = move_toward(char_velocity.x, lateral_direction * lateral_speed * 0.2, lateral_speed_acceleration)
			
		# 如果计时超过时间，就大跳，直到横移结束归0
		elif is_lateral_moving and lateral_movement_timer.time_left <= lateral_input_max_time - lateral_input_gap_time:
			lateral_jump(lateral_common_jump)
			char_velocity.x = move_toward(char_velocity.x, lateral_direction * lateral_speed * water_move_foctor, lateral_speed_acceleration)
		
	else:
		is_lateral_moving = false
		char_velocity.x = move_toward(char_velocity.x, 0, 500*delta)

func lateral_jump(jump_force:float):
	if is_on_floor() and !is_meet_wall():
		char_velocity.y = -jump_force

#endregion

#region 纵向移动
func lengthwise_move(lengthwise_move_type:LengthwiseMoveType,delta:float):
	if lengthwise_move_type == LengthwiseMoveType.CLAMP:
		climb_ladder(delta)
		is_clamping = true
	elif lengthwise_move_type == LengthwiseMoveType.JUMP:
		big_jump(delta)
		is_clamping = false
	else:
		is_clamping = false


func get_lengthwise_move_type_by_input()->LengthwiseMoveType:
	if can_reset_jump_times():
		reset_jump_times()
	if Input.is_action_pressed("move_up") and ladder_check.is_colliding() and can_clamp:
		return LengthwiseMoveType.CLAMP
	elif Input.is_action_just_pressed("move_up") and current_jump_times > 0:
		return LengthwiseMoveType.JUMP
	else:
		return LengthwiseMoveType.NULL

func climb_ladder(delta:float):
	char_velocity.y = -clamp_velocity

func big_jump(delta:float):
	char_velocity.y = -jump_velocity
	if current_jump_times == 1:
		if !wall_right_down_check.is_colliding():
			char_velocity.x += jump_lateral_move * char_face_dir
		make_turn()
	current_jump_times -= 1

func clear_jump_times():
	current_jump_times = 0

func reset_jump_times():
	current_jump_times = jump_times

func can_reset_jump_times()->bool:
	if is_on_floor():
		return true
	## 原作还真是进入梯子就刷新跳跃次数了
	if ladder_check.is_colliding() and !is_in_water():
		return true
	return false

func make_turn():
	var tween = get_tree().create_tween()
	tween.tween_property(char_body.image,"rotation_degrees",360 * char_face_dir ,turn_time)
	char_body.image.rotation_degrees = 0

#endregion

#region 偏转控制

# 机制
# 偏转程度与横向速度有关。有可能不进行三个状态的划分而是一个公式解决。

func move_dir_control(delta:float):
	if char_velocity.x > 0:
		char_body.image.flip_h = false
		char_face_dir = 1
	elif char_velocity.x < 0:
		char_body.image.flip_h = true
		char_face_dir = -1

func move_deflexion_control(delta:float):
	var curr_speed:float = char_velocity.x
	
	# 根据speed来决定偏转大小，根据speed和dir来决定偏转方向
	# 超过横向速度最大值，就直接偏转90度。
	var lateral_speed_ratio = (curr_speed/lateral_speed)
	var deflexion_angle = min(90,abs(move_rotation_degrees * lateral_speed_ratio)) * char_face_dir
	if is_meet_wall():
		char_rotation_degrees = 0
	else:
		char_rotation_degrees = move_toward(char_rotation_degrees,deflexion_angle,rotation_change_speed*delta)

func is_meet_wall()->bool:
	if wall_right_down_check.is_colliding() or wall_right_up_check.is_colliding():
		return true
	if wall_left_down_check.is_colliding() or wall_left_up_check.is_colliding():
		return true
	return false

#endregion

## 空中、水中的处理方式
## 在空中有重力，水中也有
## 空中对应地板，水中也需要设置一个地板
## 水中地板以上下沉，地板以下立即给一个向上的速度

func apply_gravity(delta:float):
	char_velocity.y = min(char_velocity.y +  get_gravity(delta),MAX_FALL_VELOCITY)

func update_state_by_water():
	# 只有刚进入水时才需要获取一下top-water
	# 离开水时自动把top-water清空
	# 所以没有top-water说明他离开过水了
	if !is_in_water():
		top_water = null
		is_sink_in_water = false
		can_clamp = true
	elif is_just_in_water():
		top_water = water_layer.find_top_water(water_check.get_collider().owner)
		char_velocity.y = water_init_speed
		is_sink_in_water = false
		if !is_on_floor():
			can_clamp = false
			clear_jump_times()
	elif global_position.y + water_sprite_offect_distance > top_water.global_position.y:
		is_sink_in_water = true
		char_velocity.y = -water_up_speed
		can_clamp = true
		reset_jump_times()
	else:
		is_sink_in_water = false

func get_gravity(delta:float)->float:
	if is_in_water():
		if is_sink_in_water:
			return 0
		else:
			return water_down_speed * delta
	elif is_in_air_without_clamp_and_water():
		return length_down_speed * delta
	else:
		return 0

func is_in_water()->bool:
	return water_check.is_colliding()

func is_just_in_water()->bool:
	return !top_water and is_in_water()

func is_in_air_without_clamp_and_water()->bool:
	return !is_on_floor() and !is_clamping and !is_in_water()

func is_on_floor()->bool:
	return char_body.is_on_floor()
