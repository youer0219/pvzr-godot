extends Area2D
class_name CheckAreaComponent

## 暂时不考虑自动实现。直接设置可能更好。
#@onready var check_area: CollisionShape2D = $CheckArea
#enum Direction {LEFT ,RIGHT}
#@export var direction:Direction = Direction.RIGHT
#
#@export var up_edge_cell:int 
#@export var down_edge_cell:int
#@export var right_edge_cell:int
#@export var left_edge_cell:int
#
#const CELL_SIDE_LEN := 16
#
#
#
#func update_check_area():
	#var up_len =  (up_edge_cell + 0.5) * CELL_SIDE_LEN
	#var down_len = (down_edge_cell + 0.5) * CELL_SIDE_LEN
	#var right_len = (right_edge_cell + 0.5) * CELL_SIDE_LEN
	#var left_len = (left_edge_cell + 0.5) * CELL_SIDE_LEN

## 任务： 存在目标时发送信号。目标均不存在时也要发送信号。
var existing_targets:Array

signal target_exist
signal target_disappear

func _on_body_entered(body: Node2D) -> void:
	if !existing_targets.has(body):
		existing_targets.append(body)
		emit_targets_state()

func _on_body_exited(body: Node2D) -> void:
	if existing_targets.has(body):
		existing_targets.erase(body)
		emit_targets_state()

func emit_targets_state():
	if existing_targets.size() == 0:
		target_disappear.emit()
	else:
		target_exist.emit()
