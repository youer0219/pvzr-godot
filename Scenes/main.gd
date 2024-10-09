extends Node2D

@onready var path_finder: TransversePathFinder = %PathFinder

func _ready() -> void:
	
	await get_tree().create_timer(1).timeout
	var start_pos:Vector2 = path_finder.map_to_local(Vector2i(-24,5)) 
	var end_pos:Vector2 = path_finder.map_to_local(Vector2i(-17,8)) + Vector2(11,0)
	print("start_pos",start_pos)
	print("end_pos:",end_pos)
	var path_stack = path_finder.get_plaform_2d_path(start_pos,end_pos)
	path_stack.print_stack_path()
