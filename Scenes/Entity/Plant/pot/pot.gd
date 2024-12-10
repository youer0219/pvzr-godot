extends Node2D

@onready var visual_sprite_component: VisualSpriteComponent = $VisualSpriteComponent


func _ready() -> void:
	var is_vertical = true
	visual_sprite_component.set_sway_mode(is_vertical)
