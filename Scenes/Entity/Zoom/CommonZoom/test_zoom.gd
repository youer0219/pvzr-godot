extends CharacterBody2D

@onready var move: Move = %Move
@onready var entity_path_finder: EntityPathFinder = %EntityPathFinder
@onready var image: Sprite2D = %Image

var move_path:ExtendGDScript.Stack = ExtendGDScript.Stack.new()
var target_body:CharacterBody2D

func _ready() -> void:
	target_body = entity_path_finder.get_target_body()

func _physics_process(delta: float) -> void:
	if !target_body:return
	
	find_path()
	if move_path and move_path.count > 0 :
		move_by_path(delta)

func move_by_path(delta:float):
	move.char_velocity = velocity
	move.char_rotation_degrees = rotation_degrees
	
	var next_point_pos:Vector2 = move_path.peek().point_pos
	if position.x < next_point_pos.x:
		move.lateral_move(1,delta)
	elif position.x > next_point_pos.x:
		move.lateral_move(-1,delta)
	else:
		move.lateral_move(0,delta)
	
	if position.y > next_point_pos.y:
		move.lengthwise_move(Move.LengthwiseMoveType.JUMP,delta)
	
	if position.x == next_point_pos.x:
		move_path.pop()
	
	velocity = move.char_velocity
	rotation_degrees = move.char_rotation_degrees


func find_path():
	if target_body == null:return
	move_path = entity_path_finder.get_move_path(target_body)
