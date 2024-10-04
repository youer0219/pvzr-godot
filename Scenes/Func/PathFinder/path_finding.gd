class_name TransversePathFinder
extends Node2D

class PointInfo:
	var isFallTile:bool
	var isLeftEdge:bool
	var isRightEdge:bool
	#var isLeftWall:bool
	#var isRightWall:bool
	var isLeftWater:bool
	var isRightWater:bool
	var isPositionPoint:bool
	var PointID:int
	var Position:Vector2
	
	static func createPointInfo(pointID:int,position:Vector2i)->PointInfo:
		var new_point_info = PointInfo.new()
		new_point_info.PointID = pointID
		new_point_info.Position = position
		return new_point_info

@export_category("Data")
## 外部显示的地图
@export var outer_tilemap_layer:TileMapLayer
## 水地图
@export var water_tilemap_layer:TileMapLayer
## 地图数组  暂时不需要加入这个变量
#@export var tilemap_array:Array[TileMapLayer]
## 寻路单位所占格数
@export var unit_cells:int = 2
@export_category("Visual")
## 是否显示路径
@export var ShowDebugGraph:bool = true

const CELL_IS_EMPTY = -1
const MAX_TILE_FALL_SCAN_DEPTH = 300
const VECTOR2I_NULL = Vector2i(-10008,-10008)
const GRAPH_POINT = preload("res://Scenes/Func/PathFinder/scene/GraphPoint.tscn")

var _astar_graph:AStar2D = AStar2D.new()
var _used_cells:Array[Vector2i]
var _point_info_array:Array[PointInfo]

enum FallDirType {LEFT,RIGHT}

func _ready():
	
	_used_cells = outer_tilemap_layer.get_used_cells() + water_tilemap_layer.get_used_cells() # 理论上两者不会有交集
	
	BuildGraph()

func BuildGraph():
	AddGraphPoints()
	
	if !ShowDebugGraph:
		ConnectPoints()

#region 视觉
func _draw():
	if ShowDebugGraph:
		ConnectPoints()

# 显示【点】
func AddVisualPoint(tile:Vector2i,color:Color = Color.ALICE_BLUE ,scale:float = 1.0):
	if !ShowDebugGraph:
		return
	
	var visualPoint:Sprite2D = GRAPH_POINT.instantiate() as Sprite2D
	visualPoint.modulate = color
	if scale != 1.0 && scale > 0.1:
		visualPoint.scale *= scale
	
	visualPoint.position = map_to_local(tile)
	add_child(visualPoint)

func DrawDebugLine(to:Vector2,from:Vector2,color:Color):
	if ShowDebugGraph:
		draw_line(from,to,color)
		queue_redraw()
#endregion

#region 添加点
func AddGraphPoints():
	for tile in _used_cells:
		AddLeftEdgePoint(tile)
		AddRightEdgePoint(tile)
		AddLeftFallPoint(tile)
		AddRightFallPoint(tile)

# 添加【左边缘点】
func AddLeftEdgePoint(tile:Vector2i):
	if !can_unit_pass(tile):
		return
	
	if is_cell_empty(tile + Vector2i(-1,0)) or isTileWall(tile + Vector2i(-1,0)):
		var tileAbove = Vector2i(0,-1) + tile
		var existingPointId:int = is_cell_already_exist_in_graph(tileAbove)
		
		if existingPointId == CELL_IS_EMPTY: # 如果这个点没有添加，就添加为【左边缘点】
			var pointId:int = _astar_graph.get_available_point_id()
			var pointInfo = PointInfo.createPointInfo(pointId,Vector2i(map_to_local(tileAbove)))
			pointInfo.isLeftEdge = true
			_point_info_array.append(pointInfo)
			_astar_graph.add_point(pointId,Vector2i(map_to_local(tileAbove)))
			AddVisualPoint(tileAbove)
		else:
			get_point_info_by_id(existingPointId).isLeftEdge = true
			AddVisualPoint(tileAbove,Color("#73eff7"))

# 添加【右边缘点】
func AddRightEdgePoint(tile:Vector2i):
	if !can_unit_pass(tile):
		return
	
	if is_cell_empty(tile + Vector2i(1,0)) or isTileWall(tile + Vector2i(1,0)):
		var tileAbove = Vector2i(0,-1) + tile
		var existingPointId:int = is_cell_already_exist_in_graph(tileAbove)
		
		if existingPointId == CELL_IS_EMPTY: # 如果这个点没有添加，就添加为【左边缘点】
			var pointId:int = _astar_graph.get_available_point_id()
			var pointInfo = PointInfo.createPointInfo(pointId,Vector2i(map_to_local(tileAbove)))
			pointInfo.isRightEdge = true
			_point_info_array.append(pointInfo)
			_astar_graph.add_point(pointId,Vector2i(map_to_local(tileAbove)))
			AddVisualPoint(tileAbove,Color("#94b0c2"))
		else:
			get_point_info_by_id(existingPointId).isRightEdge = true
			AddVisualPoint(tileAbove,Color("#ffcd75"))

# 添加左边的【坠落点】
func AddLeftFallPoint(tile:Vector2i):
	var scan:Vector2i = get_start_scan_cell_for_fall_point(tile,FallDirType.LEFT)
	var fallTile:Vector2i = find_fall_point_info_cell(scan)
	if fallTile == VECTOR2I_NULL :return
	var fallTileLocal = Vector2i(map_to_local(fallTile))
	
	var existingPointId = is_cell_already_exist_in_graph(fallTile)
	
	if existingPointId == CELL_IS_EMPTY:
		var pointId:int = _astar_graph.get_available_point_id()
		var pointInfo = PointInfo.createPointInfo(pointId,fallTileLocal)
		pointInfo.isFallTile = true
		_point_info_array.append(pointInfo)
		_astar_graph.add_point(pointId,fallTileLocal)
		AddVisualPoint(fallTile,Color(1,0.35,0.1,1),0.7)
	else:
		get_point_info_by_id(existingPointId).isFallTile = true
		AddVisualPoint(fallTile,Color("#ef7d57"),0.6)

# 添加右边的【坠落点】
func AddRightFallPoint(tile:Vector2i):
	var scan:Vector2i = get_start_scan_cell_for_fall_point(tile,FallDirType.RIGHT)
	var fallTile:Vector2i = find_fall_point_info_cell(scan)
	if fallTile == VECTOR2I_NULL :return
	var fallTileLocal = Vector2i(map_to_local(fallTile))
	
	var existingPointId = is_cell_already_exist_in_graph(fallTile)
	
	if existingPointId == CELL_IS_EMPTY:
		var pointId:int = _astar_graph.get_available_point_id()
		var pointInfo = PointInfo.createPointInfo(pointId,fallTileLocal)
		pointInfo.isFallTile = true
		_point_info_array.append(pointInfo)
		_astar_graph.add_point(pointId,fallTileLocal)
		AddVisualPoint(fallTile,Color(1,0.35,0.1,1),0.7)
	else:
		get_point_info_by_id(existingPointId).isFallTile = true
		AddVisualPoint(fallTile,Color("#ef7d57"),0.6)



#endregion 

#region 连接点
func ConnectPoints():
	for p1 in _point_info_array:
		ConnectHorizontalPoints(p1)
		ConnectFallPoints(p1)

func ConnectHorizontalPoints(p1:PointInfo):
	if p1.isLeftEdge  || p1.isFallTile:
		var closest:PointInfo = null
		
		for p2 in _point_info_array:
			if p1.PointID == p2.PointID:continue
			if (p2.isRightEdge || p2.isFallTile) && p2.Position.y == p1.Position.y && p2.Position.x > p1.Position.x:
				if closest == null:
					closest = PointInfo.createPointInfo(p2.PointID,p2.Position)
				if p2.Position.x < closest.Position.x:
					closest.Position = p2.Position
					closest.PointID = p2.PointID
		
		if closest != null:
			if !HorizontalConnectionCannotBeMade(Vector2i(p1.Position),Vector2i(closest.Position)):
				_astar_graph.connect_points(p1.PointID,closest.PointID)
				DrawDebugLine(p1.Position,closest.Position,Color(0,1,0,1))

func HorizontalConnectionCannotBeMade(p1:Vector2i,p2:Vector2i)->bool:
	var startScan = local_to_map(p1)
	var endScan = local_to_map(p2)
	
	for i in range(startScan.x,endScan.x):
		if !is_cell_empty(Vector2i(i,startScan.y)) || is_cell_empty(Vector2i(i,startScan.y + 1)) || !is_cell_empty(Vector2i(i,startScan.y -1)):
			return true
	return false

func ConnectFallPoints(p1:PointInfo):
	if (isLeftEdgeWithoutWall(p1)) || (isRightEdgeWithoutWall(p1)):
		var tilePos = local_to_map(p1.Position)
		tilePos.y += 1
		
		var left_scan:Vector2i = get_start_scan_cell_for_fall_point(tilePos,FallDirType.LEFT)
		var fallLeftPoint:Vector2i = find_fall_point_info_cell(left_scan)
		var right_scan:Vector2i = get_start_scan_cell_for_fall_point(tilePos,FallDirType.RIGHT)
		var fallRightPoint:Vector2i = find_fall_point_info_cell(right_scan)
		
		if fallLeftPoint != VECTOR2I_NULL:
			var pointInfo = get_point_info_by_cell(fallLeftPoint)
			var p2Map:Vector2 = local_to_map(p1.Position)
			var p1Map:Vector2 = local_to_map(pointInfo.Position)
			
			_astar_graph.connect_points(p1.PointID,pointInfo.PointID)
			DrawDebugLine(p1.Position,pointInfo.Position,Color(1,1,0,1))

		if fallRightPoint != VECTOR2I_NULL:
			var pointInfo = get_point_info_by_cell(fallRightPoint)
			var p2Map:Vector2 = local_to_map(p1.Position)
			var p1Map:Vector2 = local_to_map(pointInfo.Position)
			
			_astar_graph.connect_points(p1.PointID,pointInfo.PointID)
			DrawDebugLine(p1.Position,pointInfo.Position,Color(1,1,0,1))
#endregion

#region 寻找路径 
func get_plaform_2d_path(startPos:Vector2,endPos:Vector2)->ExtendGDScript.Stack:
	var pathStack = ExtendGDScript.Stack.new()

	var idPath = _astar_graph.get_id_path(_astar_graph.get_closest_point(startPos),_astar_graph.get_closest_point(endPos))

	if idPath.size() <= 0:return pathStack
	
	var startPoint = get_bottom_point_info_by_position(startPos)
	var endPoint = get_bottom_point_info_by_position(endPos)
	var numPointsInPath = idPath.size()
	
	for i in numPointsInPath:
		var currPoint = get_point_info_by_id(idPath[i])
		
		if numPointsInPath == 1:
			continue
		
		if i == 0 && numPointsInPath >= 2:
			var secondPathPoint = get_point_info_by_id(idPath[i+1])
			
			if startPoint.Position.distance_to(secondPathPoint.Position) < currPoint.Position.distance_to(secondPathPoint.Position):
				pathStack.push(startPoint)
				continue
		elif i == numPointsInPath - 1 && numPointsInPath >= 2:
			var penultimatePoint = get_point_info_by_id(idPath[i - 1])
			
			if endPoint.Position.distance_to(penultimatePoint.Position) < currPoint.Position.distance_to(penultimatePoint.Position):
				continue
			else:
				pathStack.push(currPoint)
				break
		pathStack.push(currPoint)
	pathStack.push(endPoint)
	return ExtendGDScript.Stack.ReversePathStack(pathStack)

# 与原先不同的是，我要达到的目的是找到最下面的一个点，这在游戏中肯定存在（不过最好写上不存在的处理方法） 
func get_bottom_point_info_by_position(position:Vector2)->PointInfo:
	var tile:Vector2i = local_to_map(position)
	# 找到下面的坠落点
	var fallTile = find_fall_point_info_cell(tile)
	var existingPointId = is_cell_already_exist_in_graph(fallTile)
	# 如果这个点不存在
	if existingPointId == CELL_IS_EMPTY:
		var fallTileLocal = Vector2i(map_to_local(fallTile))
		var newInfoPoint = PointInfo.createPointInfo(-10000,fallTileLocal)
		newInfoPoint.isFallTile = true
		return newInfoPoint
	# 如果这个点存在
	else:
		return get_point_info_by_id(existingPointId)

#endregion

#region 辅助函数

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
		if point_info.PointID == point_id:
			return point_info
	return null

# 判断一个局部坐标是否在图中 
func is_cell_already_exist_in_graph(tile:Vector2i)->int:
	var localPos = map_to_local(tile)
	
	if (_astar_graph.get_point_count() > 0):
		var pointId = _astar_graph.get_closest_point(localPos)
		
		if _astar_graph.get_point_position(pointId) == localPos:
			return pointId
	
	return CELL_IS_EMPTY

# 通过坐标获取PointInfo 
func get_point_info_by_cell(cell:Vector2i)->PointInfo:
	for point_info in _point_info_array:
		if point_info.Position == map_to_local(cell):
			return point_info
	return null
#region 寻找【坠落点】的辅助函数
# 获取开始坠落的点 
func get_start_scan_cell_for_fall_point(cell:Vector2i,dir:FallDirType)->Vector2i:
	var above_cell = cell + Vector2i(0,-1)
	var point_info = get_point_info_by_cell(above_cell)
	
	if point_info == null:return VECTOR2I_NULL
	
	var scan_cell = VECTOR2I_NULL
	
	if isLeftEdgeWithoutWall(point_info) and dir == FallDirType.LEFT:
		scan_cell = cell + Vector2i(-1,-1)
	elif isRightEdgeWithoutWall(point_info) and dir == FallDirType.RIGHT:
		scan_cell = cell + Vector2i(1,-1)
	return scan_cell


# 从开始坠落的点下坠直到平台 
func find_fall_point_info_cell(scan:Vector2i)->Vector2i:
	if scan == VECTOR2I_NULL :
		return VECTOR2I_NULL
	
	var scan_cell:Vector2i = scan
	var fall_cell:Vector2i = VECTOR2I_NULL
	for i in MAX_TILE_FALL_SCAN_DEPTH:
		if !is_cell_empty(scan_cell + Vector2i(0,1)):
			fall_cell = scan_cell
			break
		scan_cell.y += 1
	
	## 判断下坠点是否合法 必须在下坠点生成过程中判断，因为用到这一过程的不止一个函数
	if !can_unit_pass(fall_cell):
		return VECTOR2I_NULL
	return fall_cell

#endregion 
#region 判断边缘点是否是wall
func isLeftEdgeWithoutWall(p1:PointInfo)->bool:
	if !p1.isLeftEdge:
		return false
	var tile = local_to_map(p1.Position) + Vector2i(0,1)
	if isTileWall(tile + Vector2i(-1,0)):
		return false
	return true

func isRightEdgeWithoutWall(p1:PointInfo)->bool:
	if !p1.isRightEdge:
		return false
	var tile = local_to_map(p1.Position) + Vector2i(0,1)
	if isTileWall(tile + Vector2i(1,0)):
		return false
	return true

func isTileWall(tile:Vector2i)->bool:
	if !is_cell_empty(tile) and !can_unit_pass(tile):
		return true
	return false

#endregion
# 考虑到“水”和外层地图的position一致，其map_to_local相等
func map_to_local(tile:Vector2i)->Vector2:
	return outer_tilemap_layer.map_to_local(tile)

func local_to_map(pos:Vector2)->Vector2i:
	return outer_tilemap_layer.local_to_map(pos)
#endregion
