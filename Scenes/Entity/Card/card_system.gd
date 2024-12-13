extends Node2D
class_name CardSystem


var curr_card_texture:CardTexture

func _ready() -> void:
	var new_card = preload("res://Scenes/Entity/Card/card_textrue.tscn").instantiate()
	curr_card_texture = new_card
	add_child(new_card)


func _process(delta: float) -> void:
	card_follow(delta)

func card_follow(delta:float):
	if curr_card_texture:
		var mouse_pos = get_global_mouse_position()
		curr_card_texture.global_position = lerp(curr_card_texture.global_position,mouse_pos,delta*10) 

func has_curr_card():
	return curr_card_texture != null

func get_curr_plant_scene()->PackedScene:
	if curr_card_texture:
		return curr_card_texture.plant_scene
	return null
