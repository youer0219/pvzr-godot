extends Node2D


enum State {Idle,Attack}


@export var gap_time:float = 0.25
@export var attack_offect_angle:float = 60
@export var fire_bullet_component:FireBulletComponent

func _ready() -> void:
	attack_tween = get_tree().create_tween().set_loops().bind_node(self)
	attack()

# 攻击动画
var attack_tween:Tween
func attack():
	var curr_degerss = rotation_degrees
	attack_tween.tween_interval(gap_time * 4)
	attack_tween.tween_property(self,"rotation_degrees",curr_degerss + attack_offect_angle/2, gap_time/2 )
	attack_tween.tween_callback(fire_bullet_component.fire)
	attack_tween.tween_property(self,"rotation_degrees",curr_degerss + attack_offect_angle, gap_time/2 )
	attack_tween.tween_property(self,"rotation_degrees",curr_degerss, gap_time )
	attack_tween.tween_interval(gap_time * 2)
