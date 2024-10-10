extends Node
class_name EntityPathFinder

var target_body:CharacterBody2D
var path_finder:MapPathFinder


func _ready() -> void:
	path_finder = get_tree().get_first_node_in_group("path_finder")

func get_move_path():
	pass

func improve_move_path():
	pass
