extends Button


var build_system:BuildSystem

func _ready() -> void:
	build_system = get_tree().get_first_node_in_group("BuildSystem")
	button_down.connect(build_system.add_random_card)
