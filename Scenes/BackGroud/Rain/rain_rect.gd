extends ColorRect

@export var is_raining:bool = false:set = set_is_raining
@export var max_slant:float = 0.4
@export var slant_speed:float = 0.005
@export var is_follow:bool
var dave:CharacterBody2D
var slant:float = 0


func _ready() -> void:
	update_rain()
	dave = get_tree().get_first_node_in_group("Dave")

func _physics_process(delta: float) -> void:
	if is_follow:
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

func random_set_rain():
	if material == null:
		return
	var is_rain:bool = false if randf_range(0,1.0) > 0.5 else true
	material.set_shader_parameter("is_rain",is_rain)
	material.set_shader_parameter("rain_color",Color(1,1,1,randf_range(0.6,1.0)))
	var rain_amount = randi_range(150,500)
	material.set_shader_parameter("rain_amount",rain_amount)
	print("rain_amount: ",rain_amount)
	material.set_shader_parameter("base_rain_speed",randf_range(0.7,1.0))
	material.set_shader_parameter("additional_rain_speed",randf_range(0.6,0.8))
	material.set_shader_parameter("near_rain_transparenc",randf_range(0.6,1.0))
	
	if !is_follow:
		material.set_shader_parameter("slant",randf_range(-0.3,0.3))

func update_rain():
	if !is_raining:
		material = null
		return
	else:
		if material == null:
			var rain_material = load("res://Scenes/BackGroud/细雨.tres")
			material = rain_material
		random_set_rain()
