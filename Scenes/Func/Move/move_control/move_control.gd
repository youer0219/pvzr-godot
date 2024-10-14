extends Node
class_name MoveControl
@export var move:Move

@onready var entity_path_finder: EntityPathFinder = %EntityPathFinder
@onready var path_find_gap_timer: Timer = %PathFindGapTimer

var target_body:CharacterBody2D
var move_path:Array[Vector2]
var curr_point:Vector2
var next_point:Vector2

func _ready() -> void:
	target_body = get_tree().get_first_node_in_group("Dave")
	path_find_gap_timer.start(0.2)

func move_by_input(delta:float):
	var lateral_direction := Input.get_axis("move_left", "move_right")
	move.lateral_move(lateral_direction,delta)
	
	var lengthwise_move_type:Move.LengthwiseMoveType = move.get_lengthwise_move_type_by_input()
	move.lengthwise_move(lengthwise_move_type,delta)

func move_by_path(delta:float):
	# 间隔寻路
	if path_find_gap_timer.time_left == 0:
		move_path = entity_path_finder.get_move_path(move.char_body.position,target_body.position)
		path_find_gap_timer.start(0.05)
		print("move_path:  ",move_path)
	
	if move_path.size() == 0 or move_path.size() == 1:return
	
	curr_point = move_path[0]
	next_point = move_path[1]
	var char_body = move.char_body
	var center_x:float
	
	if !move.is_clamping:
		center_x = next_point.x
	else:
		center_x = curr_point.x
	
	if char_body.position.x < center_x:
		move.lateral_move(1,delta)
	elif char_body.position.x > center_x:
		move.lateral_move(-1,delta)
	else:
		move.lateral_move(0,delta)
