extends Node2D

@export var gap_time:float = 0.25
@export var attack_offect_angle:float = 60
@export var bullet_direction:Bullet.Direction
@export var fire_bullet_component:FireBulletComponent
@export var check_area_componet:CheckAreaComponent
@export var visual_sprite_component: VisualSpriteComponent

func _ready() -> void:
	attack_tween = get_tree().create_tween().set_loops().bind_node(self)
	attack_tween.stop()
	attack()
	check_area_componet.target_exist.connect(start_attack)
	check_area_componet.target_disappear.connect(stop_attack)
	owner.change_direction.connect(
		func(value:Bullet.Direction):
			#print(name," bullet_direction ", value)
			bullet_direction = value
	)


# 攻击动画
var attack_tween:Tween
func attack():
	var curr_degerss = visual_sprite_component.rotation_degrees
	attack_tween.tween_interval(gap_time * 4)
	attack_tween.tween_property(visual_sprite_component,"rotation_degrees",curr_degerss + -1 * attack_offect_angle/2, gap_time/2 )
	## 不要直接绑定bullet-direction数据，因为会固定，无法更改！
	attack_tween.tween_callback(fire)
	attack_tween.tween_property(visual_sprite_component,"rotation_degrees",curr_degerss + -1 * attack_offect_angle, gap_time/3 )
	attack_tween.tween_property(visual_sprite_component,"rotation_degrees",curr_degerss, gap_time )
	attack_tween.tween_interval(gap_time * 2)

func fire():
	fire_bullet_component.fire(bullet_direction)

func start_attack():
	if !attack_tween.is_running():
		attack_tween.play()

func stop_attack():
	attack_tween.stop()
