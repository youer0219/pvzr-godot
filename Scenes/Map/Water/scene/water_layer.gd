extends TileMapLayer
class_name WaterLayer

# 找到所有第一排的“水”
# 使之浮动
func set_top_waters():
	var cells:Array[Vector2i] = get_used_cells()
	for water:AnimaWater in get_children():
		var cell = local_to_map(water.position)
		var is_top:bool = true if !cells.has(cell + Vector2i(0,-1)) else false
		if is_top:
			water.is_top = true


func _on_child_order_changed() -> void:
	if is_inside_tree():
		set_top_waters()

func find_top_water(ori_water:AnimaWater)->AnimaWater:
	if ori_water == null:
		return null
	var top_water:AnimaWater
	var cell:Vector2i = local_to_map(ori_water.position)
	var cells:Array[Vector2i] = get_used_cells()
	while 1:
		if cells.has(cell+Vector2i(0,-1)):
			cell += Vector2i(0,-1)
		else:
			break
	var water_pos:Vector2 = (map_to_local(cell))
	for water in get_children():
		if water is not AnimaWater:continue
		if water.position == water_pos:
			top_water = water
	
	return top_water
