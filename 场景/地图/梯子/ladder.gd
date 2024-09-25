extends Sprite2D


enum LadderType {TOP=0,MID=1,UNDER=2}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_frame(LadderType.MID)


func _process(delta: float) -> void:
	pass
