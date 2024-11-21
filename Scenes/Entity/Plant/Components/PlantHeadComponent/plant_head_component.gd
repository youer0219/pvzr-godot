extends Node2D

@export var gap_time:float = 0.25
@export var attack_offect_angle:float = 60
@export var sway_sprite_component:SwaySpriteComponent
@export var fire_bullet_component:FireBulletComponent
@export var check_area_componet:CheckAreaComponent
enum Direction { RIGHT = -1,LEFT = 1}
@export var direction:Direction = Direction.RIGHT

func _ready() -> void:
	attack_tween = get_tree().create_tween().set_loops().bind_node(self)
	attack_tween.stop()
	attack()
	check_area_componet.target_exist.connect(start_attack)
	check_area_componet.target_disappear.connect(stop_attack)


# 攻击动画
var attack_tween:Tween
func attack():
	var curr_degerss = sway_sprite_component.rotation_degrees
	attack_tween.tween_interval(gap_time * 4)
	attack_tween.tween_property(sway_sprite_component,"rotation_degrees",curr_degerss + direction * attack_offect_angle/2, gap_time/2 )
	attack_tween.tween_callback(fire_bullet_component.fire)
	attack_tween.tween_property(sway_sprite_component,"rotation_degrees",curr_degerss + direction * attack_offect_angle, gap_time/2 )
	attack_tween.tween_property(sway_sprite_component,"rotation_degrees",curr_degerss, gap_time )
	attack_tween.tween_interval(gap_time * 2)

func start_attack():
	if !attack_tween.is_running():
		attack_tween.play()

func stop_attack():
	attack_tween.stop()
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(self,"rotation_degrees",0,gap_time)
