extends Node2D
class_name EntityPathFinder

var target_body:CharacterBody2D
var path_finder:TransversePathFinder
var move_path:ExtendGDScript.Stack

## 目标类型
enum TargetType {DAVE,PLANT}

func _ready() -> void:
	get_path_finder()
	get_target_body()
	await get_tree().create_timer(2).timeout
	get_move_path()

## 获取目标
func get_target_body():
	target_body = get_tree().get_first_node_in_group("Dave")

## 获取地图寻路器
func get_path_finder():
	path_finder = get_tree().get_first_node_in_group("path_finder")

## 获取路径
func get_move_path():
	if !target_body:
		return
	var pos = global_position
	var target_pos = target_body.global_position
	move_path = path_finder.get_plaform_2d_path(pos,target_pos)
	move_path.print_stack_path()

## 路径更新
func update_move_path():
	get_target_body()
	get_move_path()
