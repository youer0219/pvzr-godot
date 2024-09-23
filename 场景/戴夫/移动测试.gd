extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -500.0
@export var jump_times:int = 2
var current_jump_times:int = jump_times
@export var move_rotation_degrees:int = 15
@export var rotation_change_speed:float = 40

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if can_reset_jump_times():
		current_jump_times = jump_times

	# Handle jump.
	if Input.is_action_just_pressed("move_up") and current_jump_times > 0:
		velocity.y = JUMP_VELOCITY
		current_jump_times -= 1


	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, 80)
			small_jump()
			if direction == 1:
				$Sprite2D.flip_h = false
				rotation_degrees = move_toward(rotation_degrees,move_rotation_degrees,rotation_change_speed*delta)
			elif direction == -1:
				$Sprite2D.flip_h = true
				rotation_degrees = move_toward(rotation_degrees,-move_rotation_degrees,rotation_change_speed*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, 80)
		rotation_degrees = move_toward(rotation_degrees,0,10)
	
	move_and_slide()

func small_jump():
	if is_on_floor():
		velocity.y = -150

func can_reset_jump_times()->bool:
	if is_on_floor():
		return true
	
	return false
