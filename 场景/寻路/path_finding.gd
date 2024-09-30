class_name TransversePathFinder
extends Node

class PointInfo:
	var isFallTile:bool
	var isLeftEdge:bool
	var isRightEdge:bool
	var isLeftWall:bool
	var isRightWall:bool
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

const COLLISION_LAYER = 0
const CELL_IS_EMPTY = -1
const MAX_TILE_FALL_SCAN_DEPTH = 500
const VECTOR2I_NULL = Vector2i(-10008,-10008)

var _astarGraph:AStar2D = AStar2D.new()
var _usedTiles:Array[Vector2i]
var _graphpoint:PackedScene
var _pointInfoList:Array[PointInfo]
