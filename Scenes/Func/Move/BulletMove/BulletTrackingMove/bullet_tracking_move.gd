extends BulletMove
class_name BulletTrackingMove

@export var turn_speed:float=200
@export var no_target_speed_fator:float = 0.05

var current_direction:Vector2
var curr_body:Node2D
var target_body:Node2D
var target_direction:Vector2 

var is_rotating:bool=false
var is_clockwise:bool=true
var target_angle:float
var angle_difference:float

## TODO:需要实现有无敌人下的不同移动模式

func _process(delta: float) -> void:
	rotate_move(delta)


func rotate_move(delta:float):
	if !curr_body:return
	if target_body:
		curr_body.position+=current_direction*speed*delta
		target_direction=(target_body.position - curr_body.position).normalized()
		current_direction= Vector2.UP.rotated(curr_body.rotation) #获取当前方向矢量值
		var error_value=delta*10
		angle_difference=rad_to_deg(current_direction.angle_to(target_direction))
		if(angle_difference>error_value): #根据角度正转还是反转
			curr_body.rotation_degrees+=turn_speed*delta
		elif(angle_difference<-error_value):
			curr_body.rotation_degrees-=turn_speed*delta
	else:
		current_direction= Vector2.UP.rotated(curr_body.rotation)
		curr_body.position += current_direction * speed * delta * no_target_speed_fator
