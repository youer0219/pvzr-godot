extends Plant


@onready var fire_bullet_component: FireBulletComponent = $FireBulletComponent



func _ready() -> void:
	var tween = create_tween().set_loops().bind_node(self)
	tween.tween_callback(fire)
	tween.tween_interval(1.8)


func fire():
	fire_bullet_component.fire(Bullet.Direction.RIGHT)
	fire_bullet_component.fire(Bullet.Direction.LEFT)
