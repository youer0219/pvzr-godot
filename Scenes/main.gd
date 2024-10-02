extends Node2D

func _ready() -> void:
	#print($PathFinding.TileTwoAboveEmpty(Vector2i(-34,11)))
	var test:TransversePathFinder.PointInfo = $PathFinding.GetPointInfo(Vector2i(-20,8))
	print("test.isFallTile:",test.isFallTile)
	print("test.isLeftEdge:",test.isLeftEdge)
	print("test.isRightEdge:",test.isRightEdge)
	var test2:TransversePathFinder.PointInfo = $PathFinding.GetPointInfo(Vector2i(-17,8))
	print("test2.isFallTile:",test2.isFallTile)
	print("test2.isLeftEdge:",test2.isLeftEdge)
	print("test2.isRightEdge:",test2.isRightEdge)
	#print($PathFinding.isTileWall(Vector2i(-20,9)))
	#print($PathFinding.isTileWall(Vector2i(-19,9)))
	#print($PathFinding.isTileWall(Vector2i(-27,9)))

	pass
