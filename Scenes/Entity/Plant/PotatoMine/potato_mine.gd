extends Plant


@export var active_time:float = 5.0
@export var time_fator:float = 1.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosive_component: ExplosiveComponent = $ExplosiveComponent
@onready var check_area_component: CheckAreaComponent = $CheckAreaComponent
@onready var timer: Timer = $Timer


@export var is_active:bool:set = set_is_active
var can_explosive:bool

func _ready() -> void:
	check_area_component.target_exist.connect(
		func():
			can_explosive = true
	)
	check_area_component.target_disappear.connect(
		func():
			can_explosive = false
	)
	timer.start(active_time * time_fator)
	timer.timeout.connect(
		func():
			is_active = true
	)

func _process(delta: float) -> void:
	if can_explosive and is_active:
		explosive()

func explosive():
	var explosive_effect = explosive_component.get_explosive_effect_scene()
	var node = get_tree().get_first_node_in_group("BuildSystem")
	node.add_child(explosive_effect)
	queue_free()


func set_is_active(value:bool):
	var is_same:bool = true if value == is_active else false
	is_active = value
	if !is_node_ready():
		await ready
	if !is_same:
		if is_active:
			animated_sprite_2d.play("activate")
			active_animation(-5)
		else:
			animated_sprite_2d.play("default")
			active_animation(5)


func active_animation(distance:float):
	var tween:Tween = create_tween().bind_node(self).set_ease(Tween.EASE_OUT)
	var curr_pos_y = animated_sprite_2d.position.y
	tween.tween_property(animated_sprite_2d,"position:y",curr_pos_y + distance,0.5)
