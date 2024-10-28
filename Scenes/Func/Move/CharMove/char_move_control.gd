extends Node2D

@export var char_move:CharMove
@export var entity_path_finder:EntityPathFinder
## 暂时不管，只实现按路径移动即可
enum ControlType {PATH,INPUT}
@export var control_type:ControlType

@onready var path_find_gap_timer: Timer = %PathFindGapTimer

var target_body:CharacterBody2D
var path:Array[Vector2]

func _ready() -> void:
	initialize()

func _physics_process(delta: float) -> void:
	move(delta)

## 按路径寻路指南
## 第0步：初始化
func initialize():
	path_find_gap_timer.start()
## 第一步：获取追逐对象(entity_path_finder负责)
## 第二步：获取路径(entity_path_finder提供方法，char_move_control负责使用)
func _on_path_find_gap_timer_timeout() -> void:
	path = entity_path_finder.get_entity_move_path()
## 第三步：根据路径移动(char_move_control负责)
## 常态移动方法
func move(delta:float):
	char_move.char_date_to_move()
	
	char_move.auto_move(delta)
	if char_move.can_move:
		active_move_by_path(delta)
	
	char_move.move_date_to_char()

## 按路径移动方法
func active_move_by_path(delta:float):
	update_path_after_move()
	var path_size:int = path.size()
	# 情况一：路径为0.不应主动移动.
	if path_size == 0:return
	# 情况二：路径为1(这是如何达到呢？--路径更新后可能达成这一结果)
	elif path_size == 1:
		pass
	# 情况三：路径大于1
	else:
		# 获取当前点和下一点坐标
		pass
	

## 第四步：移动前更新路径(char_move_control负责)
func update_path_after_move():
	pass
