extends CharacterBody2D

@onready var move: Move = %Move
@onready var image: Sprite2D = %Image

func _physics_process(delta: float) -> void:
	self_move(delta)

func self_move(delta:float):
	move.char_velocity = velocity
	move.char_rotation_degrees = rotation_degrees
	
	move.move_by_type(delta,move.MoveControlType.PATH)
	
	move.auto_move(delta)
	
	velocity = move.char_velocity
	rotation_degrees = move.char_rotation_degrees
	move_and_slide()
