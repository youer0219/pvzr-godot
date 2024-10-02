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

@export_category("Visual")
## 是否显示路径
@export var ShowDebugGraph:bool = true

const CELL_IS_EMPTY = -1
const MAX_TILE_FALL_SCAN_DEPTH = 300
const VECTOR2I_NULL = Vector2i(-10008,-10008)
const GRAPH_POINT = preload("res://Scenes/Func/PathFinder/scene/GraphPoint.tscn")

var _astarGraph:AStar2D = AStar2D.new()
var _usedTiles:Array[Vector2i]
var _pointInfoList:Array[PointInfo]

enum FallDirType {LEFT,RIGHT}

func _ready():
	
	_usedTiles = outer_tilemap_layer.get_used_cells() + water_tilemap_layer.get_used_cells() # 理论上两者不会有交集
	
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
	for tile in _usedTiles:
		AddLeftEdgePoint(tile)
		AddRightEdgePoint(tile)
		AddLeftFallPoint(tile)
		AddRightFallPoint(tile)

# 添加【左边缘点】
func AddLeftEdgePoint(tile:Vector2i):
	if !TileTwoAboveEmpty(tile):
		return
	
	if TileEmpty(tile + Vector2i(-1,0)) or isTileWall(tile + Vector2i(-1,0)):
		var tileAbove = Vector2i(0,-1) + tile
		var existingPointId:int = TileAlreadyExistInGraph(tileAbove)
		
		if existingPointId == -1: # 如果这个点没有添加，就添加为【左边缘点】
			var pointId:int = _astarGraph.get_available_point_id()
			var pointInfo = PointInfo.createPointInfo(pointId,Vector2i(map_to_local(tileAbove)))
			pointInfo.isLeftEdge = true
			_pointInfoList.append(pointInfo)
			_astarGraph.add_point(pointId,Vector2i(map_to_local(tileAbove)))
			AddVisualPoint(tileAbove)
		else:
			FilterListByID(existingPointId).isLeftEdge = true
			AddVisualPoint(tileAbove,Color("#73eff7"))

# 添加【右边缘点】
func AddRightEdgePoint(tile:Vector2i):
	if !TileTwoAboveEmpty(tile):
		return
	
	if TileEmpty(tile + Vector2i(1,0)) or isTileWall(tile + Vector2i(1,0)):
		var tileAbove = Vector2i(0,-1) + tile
		var existingPointId:int = TileAlreadyExistInGraph(tileAbove)
		
		if existingPointId == -1: # 如果这个点没有添加，就添加为【左边缘点】
			var pointId:int = _astarGraph.get_available_point_id()
			var pointInfo = PointInfo.createPointInfo(pointId,Vector2i(map_to_local(tileAbove)))
			pointInfo.isRightEdge = true
			_pointInfoList.append(pointInfo)
			_astarGraph.add_point(pointId,Vector2i(map_to_local(tileAbove)))
			AddVisualPoint(tileAbove,Color("#94b0c2"))
		else:
			FilterListByID(existingPointId).isRightEdge = true
			AddVisualPoint(tileAbove,Color("#ffcd75"))

# 添加左边的【坠落点】
func AddLeftFallPoint(tile:Vector2i):
	var fallTile:Vector2i = FindFallPoint(tile,FallDirType.LEFT)
	if fallTile == VECTOR2I_NULL :return
	var fallTileLocal = Vector2i(map_to_local(fallTile))
	
	var existingPointId = TileAlreadyExistInGraph(fallTile)
	
	if existingPointId == -1:
		var pointId:int = _astarGraph.get_available_point_id()
		var pointInfo = PointInfo.createPointInfo(pointId,fallTileLocal)
		pointInfo.isFallTile = true
		_pointInfoList.append(pointInfo)
		_astarGraph.add_point(pointId,fallTileLocal)
		AddVisualPoint(fallTile,Color(1,0.35,0.1,1),0.7)
	else:
		FilterListByID(existingPointId).isFallTile = true
		AddVisualPoint(fallTile,Color("#ef7d57"),0.6)

# 添加右边的【坠落点】
func AddRightFallPoint(tile:Vector2i):
	var fallTile:Vector2i = FindFallPoint(tile,FallDirType.RIGHT)
	if fallTile == VECTOR2I_NULL :return
	var fallTileLocal = Vector2i(map_to_local(fallTile))
	
	var existingPointId = TileAlreadyExistInGraph(fallTile)
	
	if existingPointId == -1:
		var pointId:int = _astarGraph.get_available_point_id()
		var pointInfo = PointInfo.createPointInfo(pointId,fallTileLocal)
		pointInfo.isFallTile = true
		_pointInfoList.append(pointInfo)
		_astarGraph.add_point(pointId,fallTileLocal)
		AddVisualPoint(fallTile,Color(1,0.35,0.1,1),0.7)
	else:
		FilterListByID(existingPointId).isFallTile = true
		AddVisualPoint(fallTile,Color("#ef7d57"),0.6)

#region 寻找【坠落点】的辅助函数
# 获取开始坠落的点
func GetStartScanTileForFallPoint(tile:Vector2i,dir:FallDirType)->Vector2i:
	var tileAbove = tile + Vector2i(0,-1)
	var point = GetPointInfo(tileAbove)
	
	if point == null:return VECTOR2I_NULL
	
	var tileScan = VECTOR2I_NULL
	
	if isLeftEdgeWithoutWall(point) and dir == FallDirType.LEFT:
		tileScan = tile + Vector2i(-1,-1)
	elif isRightEdgeWithoutWall(point) and dir == FallDirType.RIGHT:
		tileScan = tile + Vector2i(1,-1)
	return tileScan


# 从开始坠落的点下坠直到平台
func FindFallPoint(tile:Vector2i,dir:FallDirType)->Vector2i:
	var scan = GetStartScanTileForFallPoint(tile,dir)
	if scan == VECTOR2I_NULL :
		return VECTOR2I_NULL
	
	var tileScan:Vector2i = scan
	var fallTile:Vector2i = VECTOR2I_NULL
	for i in MAX_TILE_FALL_SCAN_DEPTH:
		if !TileEmpty(tileScan + Vector2i(0,1)):
			fallTile = tileScan
			break
		tileScan.y += 1
	
	## 判断下坠点是否合法 必须在下坠点生成过程中判断，因为用到这一过程的不止一个函数
	if !TileTwoAboveEmpty(fallTile):
		return VECTOR2I_NULL
	return fallTile

#endregion 

#endregion 

#region 连接点
func ConnectPoints():
	for p1 in _pointInfoList:
		ConnectHorizontalPoints(p1)
		ConnectFallPoints(p1)

func ConnectHorizontalPoints(p1:PointInfo):
	if p1.isLeftEdge  || p1.isFallTile:
		var closest:PointInfo = null
		
		for p2 in _pointInfoList:
			if p1.PointID == p2.PointID:continue
			if (p2.isRightEdge || p2.isFallTile) && p2.Position.y == p1.Position.y && p2.Position.x > p1.Position.x:
				if closest == null:
					closest = PointInfo.createPointInfo(p2.PointID,p2.Position)
				if p2.Position.x < closest.Position.x:
					closest.Position = p2.Position
					closest.PointID = p2.PointID
		
		if closest != null:
			if !HorizontalConnectionCannotBeMade(Vector2i(p1.Position),Vector2i(closest.Position)):
				_astarGraph.connect_points(p1.PointID,closest.PointID)
				DrawDebugLine(p1.Position,closest.Position,Color(0,1,0,1))

func HorizontalConnectionCannotBeMade(p1:Vector2i,p2:Vector2i)->bool:
	var startScan = local_to_map(p1)
	var endScan = local_to_map(p2)
	
	for i in range(startScan.x,endScan.x):
		if !TileEmpty(Vector2i(i,startScan.y)) || TileEmpty(Vector2i(i,startScan.y + 1)):
			return true
	return false

func ConnectFallPoints(p1:PointInfo):
	if (isLeftEdgeWithoutWall(p1)) || (isRightEdgeWithoutWall(p1)):
		var tilePos = local_to_map(p1.Position)
		tilePos.y += 1
		
		var fallLeftPoint:Vector2i = FindFallPoint(tilePos,FallDirType.LEFT)
		var fallRightPoint:Vector2i = FindFallPoint(tilePos,FallDirType.RIGHT)

		if fallLeftPoint != VECTOR2I_NULL:
			var pointInfo = GetPointInfo(fallLeftPoint)
			var p2Map:Vector2 = local_to_map(p1.Position)
			var p1Map:Vector2 = local_to_map(pointInfo.Position)
			
			_astarGraph.connect_points(p1.PointID,pointInfo.PointID,false)
			DrawDebugLine(p1.Position,pointInfo.Position,Color(1,1,0,1))

		if fallRightPoint != VECTOR2I_NULL:
			var pointInfo = GetPointInfo(fallRightPoint)
			var p2Map:Vector2 = local_to_map(p1.Position)
			var p1Map:Vector2 = local_to_map(pointInfo.Position)
			
			_astarGraph.connect_points(p1.PointID,pointInfo.PointID,false)
			DrawDebugLine(p1.Position,pointInfo.Position,Color(1,1,0,1))
#endregion

#region 辅助函数

# 如果瓷砖上两格都为空，才返回true
func TileTwoAboveEmpty(tile:Vector2i)->bool:
	if TileEmpty(tile + Vector2i(0,-1)) and TileEmpty(tile + Vector2i(0,-2)):
		return true
	return false

# 如果该点位置为空，返回true
func TileEmpty(tile:Vector2i)->bool:
	return !_usedTiles.has(tile)

# 根据id找到数组中的PointInfo 【注意，这里默认能够找到且只找到一个！】
func FilterListByID(point_id:int)->PointInfo:
	for point_info in _pointInfoList:
		if point_info.PointID == point_id:
			return point_info
	return null

# 判断一个局部坐标是否在图中
func TileAlreadyExistInGraph(tile:Vector2i)->int:
	var localPos = map_to_local(tile)
	
	if (_astarGraph.get_point_count() > 0):
		var pointId = _astarGraph.get_closest_point(localPos)
		
		if _astarGraph.get_point_position(pointId) == localPos:
			return pointId
	
	return -1

# 通过坐标获取PointInfo
func GetPointInfo(tile:Vector2i)->PointInfo:
	for point_info in _pointInfoList:
		if point_info.Position == map_to_local(tile):
			return point_info
	return null

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
	if !TileEmpty(tile) and !TileTwoAboveEmpty(tile):
		return true
	return false

#endregion
# 考虑到“水”和外层地图的position一致，其map_to_local相等
func map_to_local(tile:Vector2i)->Vector2:
	return outer_tilemap_layer.map_to_local(tile)

func local_to_map(pos:Vector2)->Vector2i:
	return outer_tilemap_layer.local_to_map(pos)
#endregion
