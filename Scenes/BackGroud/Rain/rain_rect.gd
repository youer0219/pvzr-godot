extends ColorRect

@export var is_raining:bool = false:set = set_is_raining
@export var max_slant:float = 0.4
@export var slant_speed:float = 0.005

var dave:CharacterBody2D
var slant:float = 0


func _ready() -> void:
	update_rain()
	dave = get_tree().get_first_node_in_group("Dave")

func _physics_process(delta: float) -> void:
	follow(delta)

func follow(delta:float):
	if dave == null or material == null:
		return
	
	var speed:float = dave.velocity.x
	#if is_equal_approx(slant_speed,0):
		#slant_speed = delta
	
	if is_equal_approx(speed,0):
		slant = move_toward(slant,0,slant_speed )
	elif speed > 0:
		slant = move_toward(slant,-max_slant,slant_speed)
	else:
		slant = move_toward(slant,max_slant,slant_speed)
	
	material.set_shader_parameter("slant",slant)


func set_is_raining(value:bool):
	is_raining = value
	update_rain()

func update_rain():
	if !is_raining:
		material = null
		return
	elif material == null:
		var rain_material = load("res://Scenes/BackGroud/细雨.tres")
		material = rain_material
