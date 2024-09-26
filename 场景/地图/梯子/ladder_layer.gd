extends TileMapLayer

func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	set_ladders_frame()


# 梯子规律
# 无上无下即为中，有上有下也为中
# 无上有下为上
# 有上无下为下

# 额外注意到僵尸攻击后不可主动移动一段时间（在梯子上为掉下来一段距离）

func set_ladders_frame():
	var cells:Array[Vector2i] = get_used_cells()
	for cell in cells:
		_set_ladder_frame(cell,cells)

func _set_ladder_frame(cell:Vector2i,cells:Array[Vector2i]):
	var has_up:bool = true if cells.has(cell + Vector2i(0,-1)) else false
	var has_down:bool = true if cells.has(cell + Vector2i(0,1)) else false
	var ladder:Ladder = _find_ladder_scene_by_cell(cell)
	if !ladder:return
	if (has_down and has_up) or (!has_down and !has_up):
		ladder.set_frame(Ladder.LadderType.MID)
	elif !has_up and has_down:
		ladder.set_frame(Ladder.LadderType.TOP)
	else:
		ladder.set_frame(Ladder.LadderType.UNDER)

func _find_ladder_scene_by_cell(cell:Vector2i)->Ladder:
	for ladder:Ladder in get_children():
		if ladder.global_position == to_global(map_to_local(cell)):
			return ladder
	
	return null
