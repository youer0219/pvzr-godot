extends Node


# 目标：对于一般移动，刚开始时获取其方位即可；对于需要实时改变的移动，就持续追踪目标

# bullet
@export var bullet:Bullet
@export var speed:float = 100

var direction:int = 1

func _ready() -> void:
	bullet.change_direction.connect(
		func(value:Bullet.Direction):
			print("bullt value:",value)
			if value == Bullet.Direction.RIGHT:
				direction = 1
			else:
				direction = -1
	)

func _physics_process(delta: float) -> void:
	bullet.position.x += direction * speed * delta
