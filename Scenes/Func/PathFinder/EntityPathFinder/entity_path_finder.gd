extends Node2D
class_name EntityPathFinder

#var target_body:CharacterBody2D
#var path_finder:MapPathFinder
#var move_path:ExtendGDScript.Stack

## 目标类型
#enum TargetType {DAVE,PLANT}

#func _ready() -> void:
	#get_path_finder()
	#get_target_body()
	#await get_tree().create_timer(2).timeout
	#get_move_path()

### 获取目标
#func get_target_body()->CharacterBody2D:
	#return get_tree().get_first_node_in_group("Dave")
#
### 获取地图寻路器
#func get_path_finder()->MapPathFinder:
	#return get_tree().get_first_node_in_group("path_finder")
#
### 获取路径
#func get_move_path(target_body:CharacterBody2D)->ExtendGDScript.Stack:
	##var target_body:CharacterBody2D = get_target_body()
	#var move_path:ExtendGDScript.Stack
	#if !target_body:
		#return
	#var pos = global_position
	#var target_pos = target_body.global_position
	#return get_path_finder().get_plaform_2d_path(pos,target_pos)

## 路径更新
#func update_move_path():
	#get_target_body()
	#get_move_path()
