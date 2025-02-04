extends Node2D


@onready var rain_rect: RainRect = $WeatherLayer/RainRect
@onready var lightning_curtain:LightningCurtain = $LightningCurtain
@onready var background_color: TextureRect = $Background/BackgroundColor
@onready var background_map: TileMapLayer = $Background/ParallaxLayer/BackgroundMapCanvasGroup/BackgroundMap
@onready var background_map_canvas_group: CanvasGroup = $Background/ParallaxLayer/BackgroundMapCanvasGroup

# 环境：白天 + 黑夜 + 红天 + 其他
# 天气：雨 + 闪电

enum SkyState {Daytime,Nighttime,RedSky,Fantasy}
## 已随机化
@export var sky_state:SkyState = SkyState.Daytime:set = set_sky_state

const BLUE = preload("res://Scenes/BackGroud/Blue.tres")
const NIGHT = preload("res://Scenes/BackGroud/Night.tres")
const RED = preload("res://Scenes/BackGroud/Red.tres")
const SUNSET = preload("res://Common/Shader/Fantasy/sunset.tres")
const WAVE = preload("res://Common/Shader/Fantasy/wave.tres")
const CLOUD = preload("res://Common/Shader/Fantasy/cloud.tres")


func _ready() -> void:
	sky_state = SkyState.values().pick_random()
	#sky_state = SkyState.Nighttime
	pass


func set_sky_state(value:SkyState):
	sky_state = value
	if !is_node_ready():
		await ready
	
	lightning_curtain.is_runing = false
	rain_rect.is_raining = false
	match sky_state:
		SkyState.Daytime:
			#background_map.self_modulate = Color(1,1,1,1)
			background_map_canvas_group.modulate = Color(1,1,1,1)
			background_color.texture = BLUE
			background_color.material = null
			rain_rect.is_raining = true if randf_range(0,1) < 0.5 else false
		SkyState.Nighttime:
			print("night-time")
			#background_map.self_modulate = Color("adadad")
			background_map_canvas_group.modulate = Color("adadad")
			background_color.texture = NIGHT
			background_color.material = null
			lightning_curtain.is_runing = true if randf_range(0,1) < 0.5 else false
			rain_rect.is_raining = true if randf_range(0,1) < 0.5 else false
		SkyState.RedSky:
			#background_map.self_modulate = Color(1,1,1,1)
			background_map_canvas_group.modulate = Color(1,1,1,1)
			background_color.texture = RED
			background_color.material = null
		SkyState.Fantasy:
			#background_map.self_modulate = Color(1,1,1,1)
			background_map_canvas_group.modulate = Color(1,1,1,1)
			background_color.material = SUNSET
			background_color.material.set_shader_parameter("total_phases",randi_range(5,7))
			background_color.material.set_shader_parameter("beam_height",randf_range(0.01,0.025))
			background_color.material.set_shader_parameter("beam_width",randf_range(0.28,0.40))


	
