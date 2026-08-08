extends Area2D
class_name PlayerProjectile

const OFFSCREEN_MARGIN := 64.0

@export var speed := 1100.0
@export var lifetime := 3.0

var direction := Vector2.UP
var can_move := true

var _age := 0.0


func configure(spawn_direction: Vector2 = Vector2.UP, projectile_speed: float = -1.0, projectile_lifetime: float = -1.0) -> void:
	direction = spawn_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.UP

	if projectile_speed > 0.0:
		speed = projectile_speed
	if projectile_lifetime > 0.0:
		lifetime = projectile_lifetime
	_age = 0.0


func set_movement_enabled(should_enable: bool) -> void:
	can_move = should_enable
	set_physics_process(can_move)


func _ready() -> void:
	set_physics_process(can_move)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_age += delta

	if _age >= lifetime or _is_outside_viewport():
		queue_free()


func _is_outside_viewport() -> bool:
	var viewport_rect := get_viewport_rect().grow(OFFSCREEN_MARGIN)
	return not viewport_rect.has_point(global_position)
