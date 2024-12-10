extends Node2D

@onready var visual_sprite_component: VisualSpriteComponent = $VisualSpriteComponent

@export var can_blink:bool:set = set_can_blink

const SUN_FLOWER_COLOR = Color("fff100")
const MARI_GOLD_COLOR = Color("fff1f1")

enum FlowerType {SUN,GOLD}
@export var flower_type:FlowerType = FlowerType.SUN

func _ready() -> void:
	set_flower_color(flower_type)

func set_flower_color(flower_type:FlowerType):
	match flower_type:
		FlowerType.SUN:
			visual_sprite_component.set_blink_color(SUN_FLOWER_COLOR)
		FlowerType.GOLD:
			visual_sprite_component.set_blink_color(MARI_GOLD_COLOR)

func set_can_blink(value:bool):
	can_blink = value
	if !is_node_ready():
		await ready
	if can_blink:
		visual_sprite_component.start_blink()
	else:
		visual_sprite_component.stop_blink()
