extends Area2D
class_name CheckAreaComponent

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
