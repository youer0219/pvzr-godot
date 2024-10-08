extends Node2D
class_name EntityPathFinder

var target_body:CharacterBody2D
var path_finder:TransversePathFinder
var move_path

## 目标类型
enum TargetType {DAVE,PLANT}

## 获取目标
func get_target_body():
	pass

## 获取寻路器
func get_path_finder():
	path_finder = get_tree().get_first_node_in_group("path_finder")

## 获取路径
func get_move_path():
	if !target_body:
		return
	
	move_path 

## 路径更新
func update_move_path():
	pass
