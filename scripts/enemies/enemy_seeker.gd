extends Area2D
class_name EnemySeeker

signal died(score_value: int)

const OFFSCREEN_MARGIN := 96.0
const HOMING_MISSILE_SCENE := preload("res://scenes/projectiles/HomingMissile.tscn")

@export var max_hp := 4
@export var speed := 70.0
@export var score_value := 250
@export var missile_launch_interval := 2.6
@export var missile_warning_duration := 0.45
@export var active_missile_limit := 2

@onready var fire_point: Marker2D = $FirePoint
@onready var warning_visual: Line2D = $WarningVisual

var current_hp := 0
var can_move := true
var can_receive_damage := true
var can_fire := true
var projectile_container: Node
var target: Node2D

var _fire_cooldown := 0.0
var _warning_time_remaining := 0.0
var _is_dead := false


func _ready() -> void:
	reset_health()
	_fire_cooldown = missile_launch_interval * 0.5
	_apply_warning_visual()
	set_physics_process(can_move or can_fire)


func _physics_process(delta: float) -> void:
	if can_move:
		global_position.y += speed * delta

	if can_fire:
		_update_missile_launcher(delta)

	if _is_below_viewport():
		queue_free()


func set_projectile_container(container: Node) -> void:
	projectile_container = container


func set_target(target_node: Node2D) -> void:
	target = target_node


func set_gameplay_enabled(should_enable: bool) -> void:
	can_move = should_enable
	can_receive_damage = should_enable
	can_fire = should_enable
	set_physics_process(can_move or can_fire)

	if not can_fire:
		_warning_time_remaining = 0.0
		_apply_warning_visual()


func reset_health() -> void:
	current_hp = max_hp
	_is_dead = false
	can_receive_damage = true


func take_damage(amount: int) -> bool:
	if amount <= 0 or _is_dead or not can_receive_damage:
		return false

	current_hp = maxi(current_hp - amount, 0)

	if current_hp == 0:
		_die()

	return true


func _update_missile_launcher(delta: float) -> void:
	if projectile_container == null or not is_instance_valid(target):
		return

	if _warning_time_remaining > 0.0:
		_warning_time_remaining -= delta
		if _warning_time_remaining <= 0.0:
			_launch_homing_missile()
			_fire_cooldown = missile_launch_interval
		_apply_warning_visual()
		return

	_fire_cooldown -= delta
	if _fire_cooldown <= 0.0 and _get_active_missile_count() < active_missile_limit:
		_warning_time_remaining = missile_warning_duration
		_apply_warning_visual()


func _launch_homing_missile() -> void:
	if projectile_container == null or not is_instance_valid(target):
		return

	if _get_active_missile_count() >= active_missile_limit:
		return

	var missile := HOMING_MISSILE_SCENE.instantiate()
	projectile_container.add_child(missile)
	missile.global_position = fire_point.global_position

	if missile.has_method("configure"):
		var launch_direction := (target.global_position - fire_point.global_position).normalized()
		missile.configure(target, launch_direction)


func _get_active_missile_count() -> int:
	if projectile_container == null:
		return 0

	var missile_count := 0
	for projectile in projectile_container.get_children():
		if projectile is HomingMissile:
			missile_count += 1

	return missile_count


func _apply_warning_visual() -> void:
	if is_instance_valid(warning_visual):
		warning_visual.visible = _warning_time_remaining > 0.0


func _die() -> void:
	if _is_dead:
		return

	_is_dead = true
	can_move = false
	can_receive_damage = false
	can_fire = false
	_warning_time_remaining = 0.0
	_apply_warning_visual()
	died.emit(score_value)
	queue_free()


func _is_below_viewport() -> bool:
	var viewport_rect := get_viewport_rect()
	return global_position.y > viewport_rect.position.y + viewport_rect.size.y + OFFSCREEN_MARGIN
