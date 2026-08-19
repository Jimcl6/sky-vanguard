extends Area2D
class_name HomingMissile

const OFFSCREEN_MARGIN := 160.0

@export var speed := 320.0
@export var turn_rate_degrees := 105.0
@export var lifetime := 6.5
@export var damage := 1
@export var max_hp := 1
@export var arming_delay := 0.4

@onready var visual: Polygon2D = $Visual
@onready var warning_visual: Line2D = $WarningVisual

var target: Node2D
var direction := Vector2.DOWN
var can_move := true

var current_hp := 0
var _age := 0.0
var _has_finished := false


func _ready() -> void:
	current_hp = max_hp
	direction = direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.DOWN

	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	set_physics_process(can_move)
	_apply_armed_visual()


func configure(target_node: Node2D, spawn_direction: Vector2 = Vector2.DOWN) -> void:
	target = target_node
	direction = spawn_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.DOWN


func set_movement_enabled(should_enable: bool) -> void:
	can_move = should_enable
	set_physics_process(can_move)


func take_damage(amount: int) -> bool:
	if amount <= 0 or _has_finished or current_hp <= 0:
		return false

	current_hp = maxi(current_hp - amount, 0)
	if current_hp == 0:
		_finish()

	return true


func _physics_process(delta: float) -> void:
	if not can_move:
		return

	_age += delta
	_update_direction(delta)
	global_position += direction * speed * delta
	rotation = direction.angle() + PI * 0.5
	_apply_armed_visual()

	if _age >= lifetime or _is_outside_viewport():
		_finish()


func _update_direction(delta: float) -> void:
	if not is_instance_valid(target):
		return

	var desired_direction := (target.global_position - global_position).normalized()
	if desired_direction == Vector2.ZERO:
		return

	var max_turn := deg_to_rad(turn_rate_degrees) * delta
	var turn_amount := clampf(direction.angle_to(desired_direction), -max_turn, max_turn)
	direction = direction.rotated(turn_amount).normalized()


func _is_armed() -> bool:
	return _age >= arming_delay


func _apply_armed_visual() -> void:
	if is_instance_valid(warning_visual):
		warning_visual.visible = not _is_armed()

	if is_instance_valid(visual):
		visual.color = Color(1.0, 0.34, 0.22, 1.0) if _is_armed() else Color(1.0, 0.78, 0.22, 1.0)


func _is_outside_viewport() -> bool:
	var viewport_rect := get_viewport_rect().grow(OFFSCREEN_MARGIN)
	return not viewport_rect.has_point(global_position)


func _on_area_entered(area: Area2D) -> void:
	_try_damage_player(area)


func _on_body_entered(body: Node2D) -> void:
	_try_damage_player(body)


func _try_damage_player(target_area: Node) -> void:
	if _has_finished or not can_move or not _is_armed():
		return

	var damage_target := target_area
	if target_area.name == "DamageHitbox" and target_area.get_parent() != null:
		damage_target = target_area.get_parent()

	if not damage_target.has_method("take_damage"):
		return

	var did_damage: Variant = damage_target.call("take_damage", damage)
	if did_damage != true:
		return

	_finish()


func _finish() -> void:
	if _has_finished:
		return

	_has_finished = true
	can_move = false
	queue_free()
