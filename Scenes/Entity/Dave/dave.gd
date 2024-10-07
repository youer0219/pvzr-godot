extends CharacterBody2D

@onready var image: Sprite2D = %Image
@onready var move: Move = %Move


func _physics_process(delta: float) -> void:
	move.move_by_input(delta)
