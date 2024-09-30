extends Node2D




@onready var lateral_movement_timer: Timer = %LateralMovementTimer
@onready var image: Sprite2D = %Image
@onready var wall_check: RayCast2D = %WallCheck
@onready var ladder_check: RayCast2D = %LadderCheck
@onready var water_check: RayCast2D = %WaterCheck

## 移动实体
@export var char_body:CharacterBody2D
var water_layer
var top_water:AnimaWater
var velocity:Vector2


@export_group("LateralMove")
## 横向移动最大速度
@export var speed:float = 400
## 横向移动加速度
@export var speed_acceleration:float = 300
## 横向移动小小跳
@export var lateral_small_jump:float = 100
## 横向移动小跳
@export var lateral_common_jump:float = 250
@export_range(0.05,0.18) var lateral_input_gap_time:float = 0.15
var lateral_input_max_time:float = 0.2
var is_lateral_moving:bool
@export_subgroup("Deflexion")
## 偏转角度
@export var move_rotation_degrees:int = 10
## 偏转改变速度
@export var rotation_change_speed:float = 40

@export_group("LengthwiseMove")
## 下落速度
@export var length_down_speed:float = 1500
@export_subgroup("Jump")
## 可跳跃次数
@export var jump_times:int = 2
var current_jump_times:int = jump_times
## 跳跃速度
@export var jump_velocity:float = 650
@export_subgroup("Clamp")
## 攀爬速度
@export var clamp_velocity:float = 225
var is_clamping:bool
var can_clamp:bool = true

@export_group("Water")
## 在水中的下落速度
@export var water_down_speed:float = 200
@export var water_up_speed:float = 120
## 图像中心点偏移量
@export var water_sprite_offect_distance:float = -30
var in_water:bool
var has_balloon:bool


func _ready() -> void:
	water_layer = get_tree().get_first_node_in_group("water_layer")

func _physics_process(delta: float) -> void:
	
	velocity = char_body.velocity
	
	var lateral_direction := Input.get_axis("move_left", "move_right")
	lateral_movement(lateral_direction,delta)
	
	lengthwise_move(delta)
	
	char_body.velocity = velocity
	char_body.move_and_slide()


#region 横移移动 

func lateral_movement(lateral_direction:int,delta:float):
	if has_balloon:
		lateral_move_with_ballon(delta)
		return
	
	if lateral_direction:
		# 设置图像等方向
		image.flip_h = false if lateral_direction == 1 else true
		wall_check.scale = Vector2(1,1) if lateral_direction == 1 else Vector2(-1,-1)
		
		# 偏转角度，先判断是否有障碍，如有，回正（遇到障碍的回正似乎是上面先接触，然后下面再靠过来）
		var deflection_factor:float = 1.0 if (!is_clamping and !water_check.is_colliding()) else 0.5
		if wall_check.is_colliding():
			char_body.rotation_degrees = move_toward(char_body.rotation_degrees,0,100*delta)
		else:
			char_body.rotation_degrees = move_toward(char_body.rotation_degrees,move_rotation_degrees * lateral_direction * deflection_factor,100*delta)
		
		# 水的影响
		var water_move_foctor = 0.75 if water_check.is_colliding() else 1.0
		# 如果刚刚开始，就开始计时，并小跳小移动
		if !is_lateral_moving:
			lateral_movement_timer.start(lateral_input_max_time)
			is_lateral_moving = true
			lateral_jump(lateral_small_jump)
			velocity.x = move_toward(velocity.x, lateral_direction * speed * 0.2, speed_acceleration)
			
		# 如果计时超过时间，就大跳，直到横移结束归0
		elif is_lateral_moving and lateral_movement_timer.time_left <= lateral_input_max_time - lateral_input_gap_time:
			lateral_jump(lateral_common_jump)
			velocity.x = move_toward(velocity.x, lateral_direction * speed * water_move_foctor, speed_acceleration)
		
	else:
		is_lateral_moving = false
		velocity.x = move_toward(velocity.x, 0, 50)
		char_body.rotation_degrees = move_toward(char_body.rotation_degrees,0,100*delta)

func lateral_jump(jump_force:float):
	if char_body.is_on_floor() and !wall_check.is_colliding():
		velocity.y = -jump_force

# 保留给气球用
func lateral_move_with_ballon(delta:float):
	pass

#endregion

#region 纵向移动
func lengthwise_move(delta:float):
	if has_balloon:
		velocity.y = -300
		return
	
	if can_reset_jump_times():
		current_jump_times = jump_times

	if !in_water and water_check.is_colliding():
		velocity.y = 10 
		current_jump_times = 0
		can_clamp = false

	if ladder_check.is_colliding() and Input.is_action_pressed("move_up") and can_clamp:
		climb_ladder(delta)
		is_clamping = true
	elif Input.is_action_just_pressed("move_up") and current_jump_times > 0:
		big_jump(delta)
		is_clamping = false
	else:
		is_clamping = false
	
	in_water = water_check.is_colliding()
	
	if in_water and !top_water:
		top_water = water_layer.find_top_water(water_check.get_collider().owner)
	elif !in_water:
		top_water = null
	
	if not char_body.is_on_floor() and !is_clamping and !in_water:
		velocity.y += length_down_speed * delta
	elif in_water and top_water:
		float_in_water(delta)

func float_in_water(delta:float):
	var center_horizon:float = top_water.global_position.y
	var offect_distance:float = water_sprite_offect_distance
	velocity.y += water_down_speed * delta
	if global_position.y + offect_distance > center_horizon:
		velocity.y = -water_up_speed
		current_jump_times = jump_times
		can_clamp = true


func climb_ladder(delta:float):
	velocity.y = -clamp_velocity

func big_jump(delta:float):
	velocity.y = -jump_velocity
	if current_jump_times == 1:
		if !wall_check.is_colliding():
			velocity.x += 600 * wall_check.scale.x
		make_turn()
	current_jump_times -= 1

func can_reset_jump_times()->bool:
	if char_body.is_on_floor():
		return true
	if ladder_check.is_colliding() and !in_water:
		return true
	
	return false

func make_turn():
	var tween = get_tree().create_tween()
	tween.tween_property(char_body.image,"rotation_degrees",360 * wall_check.scale.x ,0.25)
	char_body.image.rotation_degrees = 0

#endregion
