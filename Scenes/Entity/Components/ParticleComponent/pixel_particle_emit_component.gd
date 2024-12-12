extends Node2D
class_name PixelParticleEmitComponent

@export var source_texture:Sprite2D
@export var num:int = 3

var pixel_particle:PixelParticle

func _ready() -> void:
	pixel_particle = get_tree().get_first_node_in_group("PixelParticle")


func emit_particles(direction:Vector2,pos:Vector2 = global_position):
	pixel_particle.emit_particles_with_texture(num,direction,source_texture.texture,pos)



#
