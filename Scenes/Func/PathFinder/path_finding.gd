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

#const COLLISION_LAYER = 0
const CELL_IS_EMPTY = -1
const MAX_TILE_FALL_SCAN_DEPTH = 500
const VECTOR2I_NULL = Vector2i(-10008,-10008)
const GRAPH_POINT = preload("res://Scenes/Func/PathFinder/scene/GraphPoint.tscn")

var _astarGraph:AStar2D = AStar2D.new()
var _usedTiles:Array[Vector2i]
var _pointInfoList:Array[PointInfo]


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
		visualPoint.scale = Vector2(scale,scale)
	
	visualPoint.position = map_to_local(tile)
	add_child(visualPoint)
#endregion

#region 添加点
func AddGraphPoints():
	for tile in _usedTiles:
		AddLeftEdgePoint(tile)
		AddRightEdgePoint(tile)
		AddFallPoint(tile)

# 添加【左边缘点】
func AddLeftEdgePoint(tile:Vector2i):
	if TileAboveExist(tile):
		return
	
	if TileEmpty(tile + Vector2i(-1,0)) or !TileEmpty(tile + Vector2i(-1,-1)):
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
	if TileAboveExist(tile):
		return
	
	if TileEmpty(tile + Vector2i(1,0)) or !TileEmpty(tile + Vector2i(1,-1)):
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

# 添加【坠落点】
func AddFallPoint(tile:Vector2i):
	var fallTile:Vector2i = FindFallPoint(tile)
	if fallTile == VECTOR2I_NULL :return
	var fallTileLocal = Vector2i(map_to_local(fallTile))
	
	var existingPointId = TileAlreadyExistInGraph(fallTile)
	
	if existingPointId == -1:
		var pointId:int = _astarGraph.get_available_point_id()
		var pointInfo = PointInfo.createPointInfo(pointId,fallTileLocal)
		pointInfo.isFallTile = true
		_pointInfoList.append(pointInfo)
		_astarGraph.add_point(pointId,fallTileLocal)
		AddVisualPoint(fallTile,Color(1,0.35,0.1,1),0.35)
	else:
		FilterListByID(existingPointId).isFallTile = true
		AddVisualPoint(fallTile,Color("#ef7d57"),0.3)

# 添加【坠落点】的辅助函数：
func GetStartScanTileForFallPoint(tile:Vector2i)->Vector2i:
	var tileAbove = tile + Vector2i(0,-1)
	var point = GetPointInfo(tileAbove)
	
	if point == null:return VECTOR2I_NULL
	
	var tileScan = VECTOR2I_NULL
	
	if point.isLeftEdge:
		tileScan = tile + Vector2i(-1,-1)
	elif point.isRightEdge:
		tileScan = tile + Vector2i(1,-1)
	return tileScan

# 添加【坠落点】的辅助函数：
func FindFallPoint(tile:Vector2i)->Vector2i:
	var scan = GetStartScanTileForFallPoint(tile)
	if scan == VECTOR2I_NULL :
		return VECTOR2I_NULL
	
	var tileScan:Vector2i = scan
	var fallTile:Vector2i = VECTOR2I_NULL
	for i in MAX_TILE_FALL_SCAN_DEPTH:
		if !TileEmpty(tileScan + Vector2i(0,1)):
			fallTile = tileScan
			break
		tileScan.y += 1
	return fallTile



#endregion 

#region 连接点
func ConnectPoints():
	pass
#endregion

#region 辅助函数
# 如果瓷砖上面为空，返回false，否则返回true
func TileAboveExist(tile:Vector2i)->bool:
	if TileEmpty(tile + Vector2i(0,-1)):
		return false
	return true

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

# 考虑到“水”和外层地图的position一致，其map_to_local相等
func map_to_local(tile:Vector2i)->Vector2:
	return outer_tilemap_layer.map_to_local(tile)

#endregion
