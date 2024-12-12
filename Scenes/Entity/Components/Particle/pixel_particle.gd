extends GPUParticles2D
class_name PixelParticle

@export var color_source_texture:Texture:set = set_color_source_texture
@export var num:int = 30
@export var angle_spread:float = 15
@export var value_spread:float = 15


func set_color_source_texture(value:Texture):
	color_source_texture = value
	process_material.set_shader_parameter("color_source_texture",color_source_texture)

func emit_particles(normal:Vector2,pos:Vector2 = global_position):
	var xform = Transform2D(0,pos)
	amount = num
	for i in num:
		var direction:int = 1 if i%2==0 else -1
		var velocity:Vector2
		## 计算velocity
		var base_value:float = 45
		var rand_value:float = randf_range(-value_spread,value_spread)
		var velocity_value:float = base_value + rand_value
		# 计算法线基本角度
		var base_angle:float = rad_to_deg(normal.angle()) # -180~180
		# 考虑偏转与散步
		var offect_angle:float = 50
		var rand_angle:float = randf_range(-angle_spread,angle_spread)
		# 角度转换方向
		var angle:float = base_angle + (offect_angle + rand_angle) * direction
		var velocity_direction:Vector2 = Vector2.RIGHT.rotated(deg_to_rad(angle)).normalized()
		velocity = (velocity_direction * velocity_value) + Vector2(0,-10)
		
		emit_particle_without_color(xform,velocity)

func emit_particle_without_color(xform:Transform2D,velocity:Vector2):
	emit_particle(xform,velocity,Color.ALICE_BLUE,Color.ALICE_BLUE,1+2+4)
