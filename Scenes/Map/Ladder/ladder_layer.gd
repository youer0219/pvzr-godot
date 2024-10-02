extends TileMapLayer

# 梯子规律
# 无上无下即为中，有上有下也为中
# 无上有下为上
# 有上无下为下

func set_ladders_frame():
	var cells:Array[Vector2i] = get_used_cells()
	for ladder in get_children():
		_set_ladder_frame(ladder,cells)

func _set_ladder_frame(ladder:Ladder,cells:Array[Vector2i]):
	var cell = local_to_map(ladder.position)
	var has_up:bool = true if cells.has(cell + Vector2i(0,-1)) else false
	var has_down:bool = true if cells.has(cell + Vector2i(0,1)) else false

	if (has_down and has_up) or (!has_down and !has_up):
		ladder.set_frame(Ladder.LadderType.MID)
	elif !has_up and has_down:
		ladder.set_frame(Ladder.LadderType.TOP)
	else:
		ladder.set_frame(Ladder.LadderType.UNDER)


func _on_child_order_changed() -> void:
	set_ladders_frame()
