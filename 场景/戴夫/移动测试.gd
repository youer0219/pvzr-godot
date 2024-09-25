extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -700.0
@export var jump_times:int = 2
var current_jump_times:int = jump_times
@export var move_rotation_degrees:int = 10
@export var rotation_change_speed:float = 40

@onready var lateral_movement_timer: Timer = %LateralMovementTimer
@onready var image: Sprite2D = %Image
@onready var wall_check: RayCast2D = %WallCheck
@onready var ladder_check: RayCast2D = %LadderCheck

@export var speed:float = 400
@export var speed_acceleration:float = 300
@export var lateral_small_jump:float = 100
@export var lateral_common_jump:float = 250
var is_lateral_moving:bool
@export var clamp_velocity:float = 225

enum move_state {COMMON,LADDER,WATER} ## 暂时留着
var is_clamping:bool 

func _physics_process(delta: float) -> void:
	
	var lateral_direction := Input.get_axis("move_left", "move_right")
	lateral_movement(lateral_direction,delta)
	
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
	
	if not is_on_floor() and !is_clamping:
		velocity.y += 1500 * delta
	
	move_and_slide()


#region 横移移动 

func lateral_movement(lateral_direction:int,delta:float):
	
	if lateral_direction:
		# 设置图像等方向
		image.flip_h = false if lateral_direction == 1 else true
		wall_check.scale = Vector2(1,1) if lateral_direction == 1 else Vector2(-1,-1)
		
		# 偏转角度，先判断是否有障碍，如有，回正（遇到障碍的回正似乎是上面先接触，然后下面再靠过来）
		var deflection_factor:float = 1.0 if !ladder_check.is_colliding() else 0.3
		if wall_check.is_colliding():
			rotation_degrees = move_toward(rotation_degrees,0,100*delta)
		else:
			rotation_degrees = move_toward(rotation_degrees,move_rotation_degrees * lateral_direction * deflection_factor,100*delta)
		
		# 如果刚刚开始，就开始计时，并小跳小移动
		if !is_lateral_moving:
			lateral_movement_timer.start(0.2)
			is_lateral_moving = true
			lateral_jump(lateral_small_jump)
			velocity.x = move_toward(velocity.x, lateral_direction * speed * 0.2, speed_acceleration)
			
		# 如果计时超过时间，就大跳，直到横移结束归0
		elif is_lateral_moving and lateral_movement_timer.time_left <= 0.05:
			lateral_jump(lateral_common_jump)
			velocity.x = move_toward(velocity.x, lateral_direction * speed, speed_acceleration)
		
	else:
		is_lateral_moving = false
		velocity.x = move_toward(velocity.x, 0, 80)
		rotation_degrees = move_toward(rotation_degrees,0,100*delta)

func lateral_jump(jump_force:float):
	if is_on_floor() and !wall_check.is_colliding():
		velocity.y = -jump_force
#endregion

#region 纵向移动
func lengthwise_move(delta:float):  ## 暂时舍弃
	if ladder_check.is_colliding():
		climb_ladder(delta)
	else:
		big_jump(delta)

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
	tween.tween_property(image,"rotation_degrees",360 * wall_check.scale.x ,0.3)
	image.rotation_degrees = 0

#endregion
