extends Node
class_name MoveControl
@export var move:Move



func move_by_input(delta:float):
	var lateral_direction := Input.get_axis("move_left", "move_right")
	move.lateral_move(lateral_direction,delta)
	
	var lengthwise_move_type:Move.LengthwiseMoveType = move.get_lengthwise_move_type_by_input()
	move.lengthwise_move(lengthwise_move_type,delta)

func move_by_path(delta:float):
	pass
