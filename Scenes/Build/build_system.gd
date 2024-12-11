extends Node2D
class_name BuildSystem


# 目前就判断下面是不是(花盆或)地图，是的话就可以种植。不然做不完。
# TODO:建造系统等待进一步的完善。

const POT = preload("res://Scenes/Entity/Plant/pot/pot.tscn")
@onready var grid_system:GridSystem = $GridSystem

@export var is_planting:bool:set = set_is_planting

var cast_collision:ShapeCast2D

func _ready() -> void:
	ready_cast_collision()

func _physics_process(delta: float) -> void:
	plant()

func plant():
	var can_plant = can_plant()
	if can_plant and Input.is_action_just_pressed("chick"):
		var new_plant = POT.instantiate()
		new_plant.position = grid_system.get_mouse_cell_center()
		add_child(new_plant)

func set_is_planting(value:bool):
	is_planting = value
	if !is_node_ready():
		await ready
	if is_planting:
		start_cast_collision()
	else:
		stop_cast_collision()

func start_cast_collision():
	cast_collision.collide_with_bodies = true
	cast_collision.collide_with_areas = true

func stop_cast_collision():
	cast_collision.collide_with_bodies = false
	cast_collision.collide_with_areas = false

#func _physics_process(delta: float) -> void:
	#print(can_plant())

func ready_cast_collision():
	cast_collision = ShapeCast2D.new()
	add_child(cast_collision)
	cast_collision.target_position = Vector2.ZERO
	var new_shape = CircleShape2D.new()
	new_shape.radius = 7
	cast_collision.shape = new_shape
	stop_cast_collision()

func can_plant():
	var mouse_cell_center = grid_system.get_mouse_cell_center()	
	# 检测当前CELL的地图和梯子.暂时不检测水.
	cast_collision.position = mouse_cell_center
	cast_collision.collision_mask = 1 + 2
	cast_collision.force_shapecast_update()
	if cast_collision.is_colliding():
		return false
	# 检测下面的CELL的地图
	cast_collision.position = mouse_cell_center + Vector2(0,16)
	cast_collision.collision_mask = 1
	cast_collision.force_shapecast_update()
	if cast_collision.is_colliding():
		return true
	return false






##
