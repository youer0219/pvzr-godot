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

func card_add(new_card_scene:PackedScene):
	var new_card = new_card_scene.instantiate()
	add_child(new_card)
	if curr_card_texture:
		card_delate()
	curr_card_texture = new_card

func card_delate():
	var old_card = curr_card_texture
	curr_card_texture = null
	old_card.queue_free()

func has_curr_card():
	return curr_card_texture != null

func get_curr_plant_scene()->PackedScene:
	if curr_card_texture:
		return curr_card_texture.plant_scene
	return null
