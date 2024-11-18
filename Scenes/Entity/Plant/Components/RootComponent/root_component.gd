extends Sprite2D

@export var swing_left_degree:float = 20.0
@export var swing_right_degree:float = 12.0
@export var gap_time:float = 0.16

#TODO 动画设置
# 基本实现。但美术效果似乎欠佳。

var tween:Tween

func _ready() -> void:
	tween = get_tree().create_tween().set_loops().bind_node(self)
	sway()

func sway():
	tween.tween_interval(0.05)
	rotation_degrees = 0
	tween.tween_property(self,"rotation_degrees",swing_left_degree,gap_time)
	tween.tween_property(self,"rotation_degrees",-swing_right_degree,gap_time*2)
	tween.tween_property(self,"rotation_degrees",0.0,gap_time)
