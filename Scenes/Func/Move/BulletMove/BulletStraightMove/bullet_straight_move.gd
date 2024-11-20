extends Node


# 目标：对于一般移动，刚开始时获取其方位即可；对于需要实时改变的移动，就持续追踪目标

# bullet
@export var bullet:Bullet
@export var speed:float = 100
enum Direction { RIGHT = 1,LEFT = -1}
@export var direction:Direction = Direction.RIGHT

func _physics_process(delta: float) -> void:
	bullet.position.x += direction * speed * delta
