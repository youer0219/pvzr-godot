extends Node
class_name BulletMove

@export var speed:float = 100

var direction:int = 1:set = set_direction

func set_direction(value):
	if value == Bullet.Direction.RIGHT:
		direction = 1
	else:
		direction = -1
