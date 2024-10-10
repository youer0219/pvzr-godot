extends CharacterBody2D

@onready var move: Move = %Move
@onready var image: Sprite2D = %Image

#var move_path:ExtendGDScript.Stack = ExtendGDScript.Stack.new()
var target_body:CharacterBody2D
var curr_point_pos:Vector2
var next_point_pos:Vector2

const TILE_CELL_SIZE = Vector2(16,16)

func _ready() -> void:
	#target_body = entity_path_finder.get_target_body()
	pass

func _physics_process(delta: float) -> void:
	if !target_body:return
	
	#find_path()
	#if move_path and move_path.count > 0 :
		#self_move(delta)

func self_move(delta:float):
	move.char_velocity = velocity
	move.char_rotation_degrees = rotation_degrees
	
	#var next_point_pos:Vector2 = move_path.peek().point_pos
	#if position.x < next_point_pos.x:
		#move.lateral_move(1,delta)
	#elif position.x > next_point_pos.x:
		#move.lateral_move(-1,delta)
	#else:
		#move.lateral_move(0,delta)
	#
	#if position.y - TILE_CELL_SIZE.y  > next_point_pos.y:
		#move.lengthwise_move(Move.LengthwiseMoveType.JUMP,delta)
	#
	#if position.x == next_point_pos.x:
		#move_path.pop()
	
	move.auto_move(delta)
	
	velocity = move.char_velocity
	rotation_degrees = move.char_rotation_degrees
	move_and_slide()

#func move_by_path(delta:float):
	#var move_path_array:Array[MapPathFinder.PointInfo] = move_path.get_stack_array()
	#var move_path_size = move_path.count
	#if move_path_size == 1:
		#pass
	#elif move_path_size > 1:
		#curr_point_pos = move_path_array[move_path_size - 1].point_pos
		#next_point_pos = move_path_array[move_path_size - 2].point_pos
		#
		#if next_point_pos.y == curr_point_pos.y:
			#if next_point_pos.x > curr_point_pos.x:
				#pass
			#elif next_point_pos.x < curr_point_pos.x:
				#pass
			#else:
				#pass
		#elif next_point_pos.x == curr_point_pos.x:
			#if curr_point_pos.y < next_point_pos.y:
				#pass
#
#
#func find_path():
	#if target_body == null:return
	#move_path = entity_path_finder.get_move_path(target_body)
#
#func improve_path():
	#pass
