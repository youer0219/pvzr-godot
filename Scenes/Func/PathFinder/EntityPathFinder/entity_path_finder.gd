extends Node
class_name EntityPathFinder

var target_body:CharacterBody2D
var path_finder:MapPathFinder
var self_body:Node2D

func _ready() -> void:
	target_body = get_tree().get_first_node_in_group("Dave")
	path_finder = get_tree().get_first_node_in_group("path_finder")
	self_body = owner

## 应该是别人来调动这个，而不是这个去修改别人
func get_entity_move_path():
	var move_path:Array[Vector2]
	assert(target_body,"EntityPathFinder no target_body")
	assert(path_finder,"EntityPathFinder no path_finder")
	return improve_path(get_move_path(self_body.global_position,target_body.global_position))

## 暂时无用
func improve_path(path:Array[Vector2])->Array[Vector2]:
	return path


func get_move_path(start_pos:Vector2,end_pos:Vector2)->Array[Vector2]:
	return path_finder.get_move_path(start_pos,end_pos)


func get_cell(pos:Vector2)->Vector2:
	return Vector2(path_finder.local_to_map(pos))
