extends Node
class_name Test


static func print_path_pos_by_stack(stack:ExtendGDScript.Stack):
	for path in stack.get_stack_array():
		if path is MapPathFinder.PointInfo:
			print("position:",path.point_pos,"id:",path.point_id)
