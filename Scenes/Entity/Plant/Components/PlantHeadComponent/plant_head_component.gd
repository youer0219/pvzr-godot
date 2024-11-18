extends Node2D


enum State {Idle,Attack}

# 摇摆动画
var sway_tween:Tween

@export var gap_time:float = 0.16

func _ready() -> void:
	sway_tween = get_tree().create_tween().set_loops().bind_node(self)
	sway()

func sway():
	var curr_pos:= global_position
	sway_tween.tween_property(self,"global_position",curr_pos + Vector2(-0.5,0),gap_time)
	sway_tween.tween_property(self,"global_position",curr_pos + Vector2(0,1),gap_time*2)
	sway_tween.tween_property(self,"global_position",curr_pos,gap_time)

# 攻击动画
