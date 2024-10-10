extends CharacterBody2D

@onready var image: Sprite2D = %Image
@onready var move: Move = %Move


func _physics_process(delta: float) -> void:
	move.char_body_move(delta)
