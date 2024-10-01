extends CharacterBody2D


@onready var image: Sprite2D = %Image


func _process(delta: float) -> void:
	velocity = Vector2(0,-10)
	move_and_slide()
