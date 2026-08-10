extends Area2D
class_name EnemyProjectile

const OFFSCREEN_MARGIN := 96.0

@export var speed := 520.0
@export var lifetime := 5.0
@export var damage := 1

var direction := Vector2.DOWN
var can_move := true

var _age := 0.0
var _has_hit := false


func configure(spawn_direction: Vector2 = Vector2.DOWN, projectile_speed: float = -1.0, projectile_lifetime: float = -1.0, projectile_damage: int = -1) -> void:
	direction = spawn_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.DOWN

	if projectile_speed > 0.0:
		speed = projectile_speed
	if projectile_lifetime > 0.0:
		lifetime = projectile_lifetime
	if projectile_damage > 0:
		damage = projectile_damage

	_age = 0.0


func set_movement_enabled(should_enable: bool) -> void:
	can_move = should_enable
	set_physics_process(can_move)


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	set_physics_process(can_move)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_age += delta

	if _age >= lifetime or _is_outside_viewport():
		queue_free()


func _is_outside_viewport() -> bool:
	var viewport_rect := get_viewport_rect().grow(OFFSCREEN_MARGIN)
	return not viewport_rect.has_point(global_position)


func _on_area_entered(area: Area2D) -> void:
	_try_damage_player(area)


func _on_body_entered(body: Node2D) -> void:
	_try_damage_player(body)


func _try_damage_player(target: Node) -> void:
	if _has_hit:
		return

	var damage_target := target
	if target.name == "DamageHitbox" and target.get_parent() != null:
		damage_target = target.get_parent()

	if not damage_target.has_method("take_damage"):
		return

	var did_damage: Variant = damage_target.call("take_damage", damage)
	if did_damage != true:
		return

	_has_hit = true
	queue_free()
