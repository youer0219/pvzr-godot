extends TileMapLayer



var is_down:bool = true


# 找到所有第一排的“水”
# 使之浮动
func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	set_top_waters()

func set_top_waters():
	var cells:Array[Vector2i] = get_used_cells()
	for water:AnimaWater in get_children():
		var cell = local_to_map(water.position)
		var is_top:bool = true if !cells.has(cell + Vector2i(0,-1)) else false
		if is_top:
			#water.animation_player.play("float")
			water.start_float()
