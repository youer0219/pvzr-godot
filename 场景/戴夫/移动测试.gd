extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -500.0
@export var jump_times:int = 2
var current_jump_times:int = jump_times
@export var move_rotation_degrees:int = 15
@export var rotation_change_speed:float = 40

enum LateralOrientation {LEFT = 1,RIGHT = -1,IDEA = 0}


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var leteral_orientation:LateralOrientation 
	
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, 80)
		small_jump()
		$Sprite2D.flip_h = false if direction == 1 else true
		$WallCheck.scale = Vector2(1,1) if direction == 1 else Vector2(-1,-1)
		rotation_degrees = move_toward(rotation_degrees,move_rotation_degrees * direction,rotation_change_speed*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, 80)
	if !direction or ($WallCheck.is_colliding() and is_on_floor()):
		rotation_degrees = move_toward(rotation_degrees,0,10)

	if can_reset_jump_times():
		current_jump_times = jump_times

	# Handle jump.
	if Input.is_action_just_pressed("move_up") and current_jump_times > 0:
		velocity.y = JUMP_VELOCITY
		if current_jump_times == 1:
			make_turn($WallCheck.scale.x)
			if !$WallCheck.is_colliding():
				velocity.x += 600 * direction
		current_jump_times -= 1
	
	move_and_slide()


func small_jump():
	if is_on_floor() and !$WallCheck.is_colliding():
		velocity.y = -150

func can_reset_jump_times()->bool:
	if is_on_floor():
		return true
	
	return false

func make_turn(direction:int):
	var tween = get_tree().create_tween()
	tween.tween_property(self,"rotation_degrees",360*direction,0.3)
	rotation_degrees = 0
