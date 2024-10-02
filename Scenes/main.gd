extends Node2D

func _ready() -> void:
	#print($PathFinding.TileTwoAboveEmpty(Vector2i(-34,11)))
	var test:TransversePathFinder.PointInfo = $PathFinding.GetPointInfo(Vector2i(-34,8))
	print("test.isFallTile:",test.isFallTile)
	print("test.isLeftEdge:",test.isLeftEdge)
	print("test.isRightEdge:",test.isRightEdge)



	pass
