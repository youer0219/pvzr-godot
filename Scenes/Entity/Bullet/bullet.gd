extends Node2D
class_name Bullet

@export var bullet_move:BulletMove
@export var is_wall_passing:bool
@onready var hitbox: Hitbox = $Hitbox
@onready var pixel_particle_emit_component: PixelParticleEmitComponent = $PixelParticleEmitComponent
@onready var world_collision_check: Area2D = $WorldCollisionCheck

enum Direction {RIGHT,LEFT}
var direction:Direction = Direction.RIGHT:set = set_direction

func _ready() -> void:
	hitbox.hit_target.connect(hit_target)
	world_collision_check.body_entered.connect(dead.unbind(1))
	if is_wall_passing:
		world_collision_check.collision_mask = 0
	await get_tree().create_timer(10.0).timeout
	queue_free()

func set_direction(value):
	direction = value
	if !is_node_ready():
		await ready
	bullet_move.direction = direction

func hit_target():
	dead()

func dead():
	var emit_direction:Vector2 = Vector2.LEFT if direction == Direction.RIGHT else Vector2.RIGHT 
	pixel_particle_emit_component.emit_particles(emit_direction,global_position)
	queue_free()
