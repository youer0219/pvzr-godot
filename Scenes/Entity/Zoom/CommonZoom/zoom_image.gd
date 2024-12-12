extends Node2D


@onready var body: VisualSpriteComponent = $Body
@onready var head: VisualSpriteComponent = $Head

var flip_h:bool:set = set_flip_h

func zoom_under_attack_blink():
	body.zoom_under_attack_blink()
	head.zoom_under_attack_blink()

func set_flip_h(value:bool):
	flip_h = value
	if !is_node_ready():
		await ready
	body.flip_h = flip_h
	head.flip_h = flip_h
