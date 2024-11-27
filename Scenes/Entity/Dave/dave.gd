extends CharacterBody2D
class_name Dave

@onready var image: Sprite2D = %Image
@onready var move: Move = %Move


func _physics_process(delta: float) -> void:
	move.char_body_move(delta)
