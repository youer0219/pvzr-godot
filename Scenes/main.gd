extends Node2D

@onready var path_finder: MapPathFinder = %PathFinder

func _ready() -> void:
	
	#$TestTimer.start(1)
	pass

func test_move_path(delay_time:int = 0):
	await get_tree().create_timer(delay_time).timeout
	print($Entities/Dave.position)
	print($Entities/Zooms/Zoom.position)
	var move_path = path_finder.get_move_path($Entities/Dave.position,$Entities/Zooms/Zoom.position)
	print(move_path)


func _on_test_timer_timeout() -> void:
	test_move_path()
