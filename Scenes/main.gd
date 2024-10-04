extends Node2D

@onready var path_finding: TransversePathFinder = $PathFinding

func _ready() -> void:
	#print($PathFinding.TileTwoAboveEmpty(Vector2i(-34,11)))
	#var test:TransversePathFinder.PointInfo = $PathFinding.GetPointInfo(Vector2i(-20,8))
	#print("test.isFallTile:",test.isFallTile)
	#print("test.isLeftEdge:",test.isLeftEdge)
	#print("test.isRightEdge:",test.isRightEdge)
	#var test2:TransversePathFinder.PointInfo = $PathFinding.GetPointInfo(Vector2i(-17,8))
	#print("test2.isFallTile:",test2.isFallTile)
	#print("test2.isLeftEdge:",test2.isLeftEdge)
	#print("test2.isRightEdge:",test2.isRightEdge)
	#print($PathFinding.isTileWall(Vector2i(-20,9)))
	#print($PathFinding.isTileWall(Vector2i(-19,9)))
	#print($PathFinding.isTileWall(Vector2i(-27,9)))
	
	await get_tree().create_timer(1).timeout
	var start_pos:Vector2 = path_finding.map_to_local(Vector2i(-24,5))
	var end_pos:Vector2 = path_finding.map_to_local(Vector2i(-17,8))
	var path = path_finding.get_plaform_2d_path(start_pos,end_pos)
	path.stack_print()
	pass
