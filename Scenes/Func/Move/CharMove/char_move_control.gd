extends Node2D

@export var char_move:CharMove

@onready var wall_check_01: RayCast2D = $WallCheck01
@onready var wall_check_02: RayCast2D = $WallCheck02


var dave:CharacterBody2D

func _ready() -> void:
	dave = get_tree().get_first_node_in_group("Dave")

func _physics_process(delta: float) -> void:
	move(delta)


func move(delta:float):
	char_move.char_date_to_move()
	if wall_check_01.is_colliding() or wall_check_02.is_colliding():
		char_move.lengthwise_move(CharMove.LengthwiseMoveType.JUMP,delta)
	var direction:int
	if dave.global_position.x > self.global_position.x:
		direction = 1
	else:
		direction = -1
	char_move.lateral_move(direction,delta)
	char_move.auto_move(delta)
	char_move.move_date_to_char()
