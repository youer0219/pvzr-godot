class_name TransversePathFinder
extends Node2D

class PointInfo:
	var is_fall_point:bool
	var is_left_edge_point:bool
	var is_right_edge_point:bool
	var is_position_point:bool
	var point_id:int
	var point_pos:Vector2
	
	enum SetType {FALL,LEFT_EDGE,RIGHT_EDGE,POSITION}
	
	func set_type(type:SetType):
		match type:
			SetType.FALL:
				is_fall_point = true
			SetType.LEFT_EDGE:
				is_left_edge_point = true
			SetType.RIGHT_EDGE:
				is_right_edge_point = true
			SetType.POSITION:
				is_position_point = true
	
	static func createPointInfo(point_id:int,position:Vector2i)->PointInfo:
		var new_point_info = PointInfo.new()
		new_point_info.point_id = point_id
		new_point_info.point_pos = position
		return new_point_info

@export_category("Data")
## 外部显示的地图
@export var outer_tilemap_layer:TileMapLayer
## 水地图
@export var water_tilemap_layer:TileMapLayer

## 寻路单位所占格数
@export var unit_cells:int = 2
@export_category("Visual")
## 是否显示路径 
@export var is_show_debug_graph:bool = true

const CELL_IS_EMPTY = -1
const MAX_TILE_FALL_SCAN_DEPTH = 200
const VECTOR2I_NULL = Vector2i(-10008,-10008)
const GRAPH_POINT = preload("res://Scenes/Func/PathFinder/scene/GraphPoint.tscn")

var _astar_graph:AStar2D = AStar2D.new()
var _used_cells:Array[Vector2i]
var _point_info_array:Array[PointInfo]

func _ready():
	build_astar_graph()

func build_astar_graph():
	init_path_finder()
	
	add_astar_graph_points()
	
	if !is_show_debug_graph:
		connect_points()

#region 视觉
func _draw():
	if is_show_debug_graph:
		connect_points()

# 显示【点】 
func add_visual_point(tile:Vector2i,color:Color = Color.ALICE_BLUE,point_scale:float = 1.0):
	if !is_show_debug_graph:
		return
	
	var visual_point_scene:Sprite2D = GRAPH_POINT.instantiate() as Sprite2D
	visual_point_scene.modulate = color
	if point_scale != 1.0 && point_scale > 0.1:
		visual_point_scene.scale *= point_scale
	
	visual_point_scene.position = map_to_local(tile)
	add_child(visual_point_scene)

# 显示【线】
func draw_debug_line(to:Vector2,from:Vector2,color:Color):
	if is_show_debug_graph:
		draw_line(from,to,color)
		queue_redraw()

#endregion

#region 添加点 
func add_astar_graph_points():
	for tile in _used_cells:
		if !can_unit_pass(tile):
			continue
		add_left_edge_point(tile)
		add_right_edge_point(tile)
	for edge_point in _point_info_array:
		add_fall_point(edge_point)

# 添加【左边缘点】
func add_left_edge_point(tile:Vector2i):
	if is_cell_empty(tile + Vector2i.LEFT) or is_cell_wall(tile + Vector2i.LEFT):
		var tileAbove = Vector2i.UP + tile
		add_point_by_cell(tileAbove,PointInfo.SetType.LEFT_EDGE,Color("#73eff7"))

# 添加【右边缘点】 
func add_right_edge_point(tile:Vector2i):
	if is_cell_empty(tile + Vector2i.RIGHT) or is_cell_wall(tile + Vector2i.RIGHT):
		var tileAbove = Vector2i.UP + tile
		add_point_by_cell(tileAbove,PointInfo.SetType.RIGHT_EDGE,Color("#ffcd75"))

func add_fall_point(edge_point:PointInfo):
	var point_tile_cell = local_to_map(edge_point.point_pos) + Vector2i.DOWN
	# 左边找点
	if is_left_edge_without_wall(edge_point):
		var scan_cell:Vector2i = point_tile_cell + Vector2i.UP + Vector2i.LEFT
		var fall_point_cell:Vector2i = find_fall_point_info_cell(scan_cell)
		add_point_by_cell(fall_point_cell,PointInfo.SetType.FALL,Color(1,0.35,0.1,1),0.7)
	# 右边找点
	if is_right_edge_without_wall(edge_point):
		var scan_cell:Vector2i = point_tile_cell + Vector2i.UP + Vector2i.RIGHT
		var fall_point_cell:Vector2i = find_fall_point_info_cell(scan_cell)
		add_point_by_cell(fall_point_cell,PointInfo.SetType.FALL,Color(1,0.35,0.1,1),0.7)

func add_point_by_cell(cell:Vector2i,type:PointInfo.SetType,color:Color = Color.ALICE_BLUE ,point_scale:float = 1.0):
	if cell == VECTOR2I_NULL:
		return
	var point_pos = Vector2i(map_to_local(cell))
	var existing_point_id:int = is_cell_already_exist_in_graph(cell)
	if existing_point_id == CELL_IS_EMPTY:
		var point_id:int = _astar_graph.get_available_point_id()
		var new_point_info:PointInfo = PointInfo.createPointInfo(point_id,point_pos)
		new_point_info.set_type(type)
		_point_info_array.append(new_point_info)
		_astar_graph.add_point(point_id,point_pos)
	else:
		get_point_info_by_id(existing_point_id).set_type(type)
	add_visual_point(cell,color,point_scale)

#endregion 

#region 连接点 
func connect_points():
	for point_info in _point_info_array:
		connect_horizontal_points(point_info)
		connect_fall_points(point_info)

func connect_horizontal_points(front_point:PointInfo):
	if front_point.is_left_edge_point  || front_point.is_fall_point:
		var closest_point:PointInfo = null
		
		for p2 in _point_info_array:
			if front_point.point_id == p2.point_id:continue
			if (p2.is_right_edge_point || p2.is_fall_point) && p2.point_pos.y == front_point.point_pos.y && p2.point_pos.x > front_point.point_pos.x:
				if closest_point == null:
					closest_point = PointInfo.createPointInfo(p2.point_id,p2.point_pos)
				if p2.point_pos.x < closest_point.point_pos.x:
					closest_point.point_pos = p2.point_pos
					closest_point.point_id = p2.point_id
		
		if closest_point != null:
			if !is_not_horizontal_connection_can_be_made(Vector2i(front_point.point_pos),Vector2i(closest_point.point_pos)):
				connect_two_point(front_point,closest_point,Color(0,1,0,1))

# 是否允许两点之间横向连线 
func is_not_horizontal_connection_can_be_made(p1:Vector2i,p2:Vector2i)->bool:
	var start_scan_cell = local_to_map(p1)
	var end_scan_cell = local_to_map(p2)
	
	for i in range(start_scan_cell.x,end_scan_cell.x):
		if !is_cell_empty(Vector2i(i,start_scan_cell.y)) || is_cell_empty(Vector2i(i,start_scan_cell.y + 1)) || !is_cell_empty(Vector2i(i,start_scan_cell.y -1)):
			return true
	return false

func connect_fall_points(point_info:PointInfo):
	# 左边寻找
	if is_left_edge_without_wall(point_info):
		var point_tile_cell = local_to_map(point_info.point_pos) + Vector2i.DOWN
		var scan_cell:Vector2i = point_tile_cell + Vector2i.UP + Vector2i.LEFT
		var fall_point_cell:Vector2i = find_fall_point_info_cell(scan_cell)
		if fall_point_cell != VECTOR2I_NULL:
			var fall_point_info = get_point_info_by_cell(fall_point_cell)
			connect_two_point(point_info,fall_point_info,Color(1,1,0,1))
	# 右边寻找
	if is_right_edge_without_wall(point_info):
		var point_tile_cell = local_to_map(point_info.point_pos) + Vector2i.DOWN
		var scan_cell:Vector2i = point_tile_cell + Vector2i.UP + Vector2i.RIGHT
		var fall_point_cell:Vector2i = find_fall_point_info_cell(scan_cell)
		if fall_point_cell != VECTOR2I_NULL:
			var fall_point_info = get_point_info_by_cell(fall_point_cell)
			connect_two_point(point_info,fall_point_info,Color(1,1,0,1))


func connect_two_point(front_point:PointInfo,back_point:PointInfo,line_color:Color):
	_astar_graph.connect_points(front_point.point_id,back_point.point_id)
	draw_debug_line(front_point.point_pos,back_point.point_pos,line_color)

#endregion

#region 寻找路径 
func get_plaform_2d_path(start_pos:Vector2,end_pos:Vector2)->ExtendGDScript.Stack:
	var path_stack = ExtendGDScript.Stack.new()

	var id_path_array = _astar_graph.get_id_path(_astar_graph.get_closest_point(start_pos),_astar_graph.get_closest_point(end_pos),true)

	if id_path_array.size() <= 0:return path_stack
	
	var start_point = get_bottom_point_info_by_position(start_pos)
	var end_point = get_bottom_point_info_by_position(end_pos)
	var id_path_array_size = id_path_array.size()
	
	for i in id_path_array_size:
		var curr_point = get_point_info_by_id(id_path_array[i])
		
		if id_path_array_size == 1:
			continue
		
		if i == 0 && id_path_array_size >= 2:
			var second_path_point = get_point_info_by_id(id_path_array[i+1])
			
			if start_point.point_pos.distance_to(second_path_point.point_pos) < curr_point.point_pos.distance_to(second_path_point.point_pos):
				path_stack.push(start_point)
				continue
		elif i == id_path_array_size - 1 && id_path_array_size >= 2:
			var penultimate_point = get_point_info_by_id(id_path_array[i - 1])
			
			if end_point.point_pos.distance_to(penultimate_point.point_pos) <= curr_point.point_pos.distance_to(penultimate_point.point_pos):
				continue
			else:
				path_stack.push(curr_point)
				break
		path_stack.push(curr_point)
	path_stack.push(end_point)
	return ExtendGDScript.Stack.ReversePathStack(path_stack)

# 要找到最下面的点，这个点的x与原坐标一致，但y与平台上的点一致，如有相同的返回那个点，如无就创建新的点
# 可能并不需要判断点是否已存在,并且position也不需要Vector2i，这个之后再看吧
func get_bottom_point_info_by_position(pos:Vector2)->PointInfo:
	var y_offect = outer_tilemap_layer.tile_set.tile_size.y / 2
	var cell:Vector2i = local_to_map(pos + Vector2(0,-y_offect)) ## 增加一下高度，避免识别到下面的格子了
	# 找到下面的坠落点
	var fall_cell = find_fall_point_info_cell(cell)
	var existing_point_id = is_cell_already_exist_in_graph(fall_cell)
	# 如果这个点不存在
	if existing_point_id == CELL_IS_EMPTY:
		var local_fall_cell = Vector2i(pos.x,map_to_local(fall_cell).y)
		var new_point_info = PointInfo.createPointInfo(-10000,local_fall_cell)
		new_point_info.set_type(PointInfo.SetType.POSITION)
		return new_point_info
	# 如果这个点存在
	else:
		var exiting_point_info = get_point_info_by_id(existing_point_id)
		exiting_point_info.set_type(PointInfo.SetType.POSITION)
		return exiting_point_info

#endregion

#region 辅助函数

func init_path_finder():
	_used_cells = outer_tilemap_layer.get_used_cells() + water_tilemap_layer.get_used_cells()
	_point_info_array = []
	_astar_graph = AStar2D.new()
	## 在ready时调用该函数无效
	for point in get_children():
		remove_child(point)
		point.queue_free()


# 判断单位能否通过：如果瓷砖上单位所占格数（unit_cells）的格子都为空，才返回true
func can_unit_pass(tile:Vector2i)->bool:
	for num in range(unit_cells):
		var should_pass_cell:Vector2i = tile + Vector2i(0,-(num+1))
		if !is_cell_empty(should_pass_cell):
			return false
	return true

# 如果该点位置为空，返回true
func is_cell_empty(cell:Vector2i)->bool:
	return !_used_cells.has(cell)

# 根据id找到数组中的PointInfo 【注意，这里默认能够找到且只找到一个！】
func get_point_info_by_id(point_id:int)->PointInfo:
	for point_info in _point_info_array:
		if point_info.point_id == point_id:
			return point_info
	return null

# 判断一个地图坐标是否有对应的点，如有，返回其ID，如无，返回CELL_IS_EMPTY
func is_cell_already_exist_in_graph(cell:Vector2i)->int:
	var local_pos = map_to_local(cell)
	
	if (_astar_graph.get_point_count() > 0):
		var point_id = _astar_graph.get_closest_point(local_pos)
		
		if _astar_graph.get_point_position(point_id) == local_pos:
			return point_id
	
	return CELL_IS_EMPTY

# 通过坐标获取PointInfo 
func get_point_info_by_cell(cell:Vector2i)->PointInfo:
	for point_info in _point_info_array:
		if point_info.point_pos == map_to_local(cell):
			return point_info
	return null

func get_point_info_down_cell(point_info:PointInfo)->Vector2i:
	return local_to_map(point_info.point_pos) + Vector2i.DOWN

# 从开始坠落的点下坠直到平台 
func find_fall_point_info_cell(scan:Vector2i)->Vector2i:
	if scan == VECTOR2I_NULL :
		return VECTOR2I_NULL
	
	var scan_cell:Vector2i = scan
	var fall_cell:Vector2i = VECTOR2I_NULL
	for i in MAX_TILE_FALL_SCAN_DEPTH:
		if !is_cell_empty(scan_cell + Vector2i.DOWN):
			fall_cell = scan_cell
			break
		scan_cell.y += 1
	
	## 判断下坠点是否合法 必须在下坠点生成过程中判断，因为用到这一过程的不止一个函数
	if !can_unit_pass(fall_cell):
		return VECTOR2I_NULL
	return fall_cell
	
#region 判断边缘点是否是wall
func is_left_edge_without_wall(point_info:PointInfo)->bool:
	if !point_info.is_left_edge_point:
		return false
	var cell = get_point_info_down_cell(point_info)
	if is_cell_wall(cell + Vector2i.LEFT):
		return false
	return true

func is_right_edge_without_wall(point_info:PointInfo)->bool:
	if !point_info.is_right_edge_point:
		return false
	var cell = get_point_info_down_cell(point_info)
	if is_cell_wall(cell + Vector2i.RIGHT):
		return false
	return true

func is_cell_wall(cell:Vector2i)->bool:
	if !is_cell_empty(cell) and !can_unit_pass(cell):
		return true
	return false

#endregion
#region tilemap的函数
# 考虑到“水”和外层地图的position一致，其map_to_local相等
func map_to_local(cell:Vector2i)->Vector2:
	return outer_tilemap_layer.map_to_local(cell)

func local_to_map(pos:Vector2)->Vector2i:
	return outer_tilemap_layer.local_to_map(pos)

#endregion

#endregion
