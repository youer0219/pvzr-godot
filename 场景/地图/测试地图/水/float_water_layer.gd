extends TileMapLayer

var should_up:bool = true
var is_move:bool = false

@export var move_distance:float = 6.0
@export var gap_time:float = 0.8
@export var is_up:bool = false

func _ready() -> void:
	if !is_up:
		move_distance *= -1
	

func move_up():
	is_move = true
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position",position + Vector2(0,-move_distance),gap_time)
	await tween.finished
	is_move = false
	should_up = false


func move_down():
	is_move = true
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position",position + Vector2(0,move_distance),gap_time)
	await tween.finished
	is_move = false
	should_up = true

func _process(delta: float) -> void:
	if !is_move:
		if should_up:
			move_up()
		else:
			move_down()
