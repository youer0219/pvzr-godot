extends CharacterBody2D


@onready var image: VisualSpriteComponent = $VisualSpriteComponent
@onready var hurtbox: Hurtbox = $Hurtbox

func _ready() -> void:
	hurtbox.under_damage.connect(under_damage_effect_apply)


func under_damage_effect_apply():
	#print(name," under damage ")
	image.zoom_under_attack_blink()
	#velocity.x -= 120
	#velocity.y -= 20
	#move_and_slide()
	# 模拟击退效果
	# TODO:这个效果需要优化。原作中的击退更像是一种状态/BUFF。
	position.x -= 10
	position.y -= 1
	velocity.x = 0
