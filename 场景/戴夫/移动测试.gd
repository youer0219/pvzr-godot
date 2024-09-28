extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -650.0

@onready var lateral_movement_timer: Timer = %LateralMovementTimer
@onready var image: Sprite2D = %Image
@onready var wall_check: RayCast2D = %WallCheck
@onready var ladder_check: RayCast2D = %LadderCheck
@onready var water_check: RayCast2D = %WaterCheck
var water_layer 

@export var jump_times:int = 2
var current_jump_times:int = jump_times
@export var move_rotation_degrees:int = 10
@export var rotation_change_speed:float = 40

@export var speed:float = 400
@export var speed_acceleration:float = 300
@export var lateral_small_jump:float = 100
@export var lateral_common_jump:float = 250
var is_lateral_moving:bool
@export var clamp_velocity:float = 225

enum move_state {COMMON,LADDER,WATER} ## 暂时留着
var is_clamping:bool
var in_water:bool
var is_first_in_water:bool
var top_water:AnimaWater

func _ready() -> void:
	water_layer = get_tree().get_first_node_in_group("water_layer")

func _physics_process(delta: float) -> void:
	
	var lateral_direction := Input.get_axis("move_left", "move_right")
	lateral_movement(lateral_direction,delta)
	
	lengthwise_move(delta)
	
	move_and_slide()



#region 横移移动 

func lateral_movement(lateral_direction:int,delta:float):
	
	if lateral_direction:
		# 设置图像等方向
		image.flip_h = false if lateral_direction == 1 else true
		wall_check.scale = Vector2(1,1) if lateral_direction == 1 else Vector2(-1,-1)
		
		# 偏转角度，先判断是否有障碍，如有，回正（遇到障碍的回正似乎是上面先接触，然后下面再靠过来）
		var deflection_factor:float = 1.0 if (!is_clamping and !water_check.is_colliding()) else 0.5
		if wall_check.is_colliding():
			rotation_degrees = move_toward(rotation_degrees,0,100*delta)
		else:
			rotation_degrees = move_toward(rotation_degrees,move_rotation_degrees * lateral_direction * deflection_factor,100*delta)
		
		# 水的影响
		var water_move_foctor = 0.75 if water_check.is_colliding() else 1.0
		# 如果刚刚开始，就开始计时，并小跳小移动
		if !is_lateral_moving:
			lateral_movement_timer.start(0.2)
			is_lateral_moving = true
			lateral_jump(lateral_small_jump)
			velocity.x = move_toward(velocity.x, lateral_direction * speed * 0.2, speed_acceleration)
			
		# 如果计时超过时间，就大跳，直到横移结束归0
		elif is_lateral_moving and lateral_movement_timer.time_left <= 0.05:
			lateral_jump(lateral_common_jump)
			velocity.x = move_toward(velocity.x, lateral_direction * speed * water_move_foctor, speed_acceleration)
		
	else:
		is_lateral_moving = false
		velocity.x = move_toward(velocity.x, 0, 50)
		rotation_degrees = move_toward(rotation_degrees,0,100*delta)

func lateral_jump(jump_force:float):
	if is_on_floor() and !wall_check.is_colliding():
		velocity.y = -jump_force
#endregion

#region 纵向移动
func lengthwise_move(delta:float):  ## 暂时舍弃
	if can_reset_jump_times():
		current_jump_times = jump_times
	
	if ladder_check.is_colliding() and Input.is_action_pressed("move_up"):
		climb_ladder(delta)
		is_clamping = true
	elif Input.is_action_just_pressed("move_up") and current_jump_times > 0:
		big_jump(delta)
		is_clamping = false
	else:
		is_clamping = false
	
	if !in_water and water_check.is_colliding():
		velocity.y *= 0.1
		current_jump_times = 0
	
	in_water = water_check.is_colliding()
	
	if in_water and !top_water:
		top_water = water_layer.find_top_water(water_check.get_collider().owner)
	elif !in_water:
		top_water = null
	
	if not is_on_floor() and !is_clamping and !in_water:
		velocity.y += 1500 * delta
	elif in_water and top_water:
		float_in_water(delta)

func float_in_water(delta:float):
	var center_horizon:float = top_water.global_position.y
	var offect_distance:float = 40
	velocity.y += 150 * delta
	if global_position.y + offect_distance > center_horizon:
		velocity.y = -75
		current_jump_times = jump_times


func climb_ladder(delta:float):
	velocity.y = -clamp_velocity

func big_jump(delta:float):
	velocity.y = JUMP_VELOCITY
	if current_jump_times == 1:
		if !wall_check.is_colliding():
			velocity.x += 600 * wall_check.scale.x
		make_turn()
	current_jump_times -= 1

func can_reset_jump_times()->bool:
	if is_on_floor():
		return true
	if ladder_check.is_colliding():
		return true
	
	return false

func make_turn():
	var tween = get_tree().create_tween()
	tween.tween_property(image,"rotation_degrees",360 * wall_check.scale.x ,0.25)
	image.rotation_degrees = 0

#endregion
