extends Node
class_name SpawnManager

signal enemy_spawned(enemy: Node)

const ENEMY_TYPE_BASIC := "basic"
const ENEMY_TYPE_SHOOTER := "shooter"
const ENEMY_TYPE_DROP_CARRIER := "drop_carrier"
const ENEMY_TYPE_SEEKER := "seeker"
const DESIGN_VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const DROP_CATEGORY_WEAPON := "weapon"
const DROP_CATEGORY_BOOSTER := "booster"
const DROP_SEQUENCE := [
	{
		"category": DROP_CATEGORY_WEAPON,
		"id": "spread_shot",
	},
	{
		"category": DROP_CATEGORY_BOOSTER,
		"id": "temporary_shield",
	},
	{
		"category": DROP_CATEGORY_WEAPON,
		"id": "basic_blaster",
	},
]

@export var basic_enemy_scene: PackedScene = preload("res://scenes/enemies/EnemyBasic.tscn")
@export var shooter_enemy_scene: PackedScene = preload("res://scenes/enemies/EnemyShooter.tscn")
@export var drop_carrier_scene: PackedScene = preload("res://scenes/enemies/EnemyDropCarrier.tscn")
@export var seeker_enemy_scene: PackedScene = preload("res://scenes/enemies/EnemySeeker.tscn")
@export var initial_spawn_delay := 1.0
@export var max_active_enemies := 8
@export var max_active_drop_carriers := 1
@export var max_active_seekers := 1
@export var spawn_margin_x := 84.0
@export var spawn_y_offset := 72.0

var enemy_container: Node
var projectile_container: Node
var player: Node

var _is_spawning_enabled := false
var _run_time := 0.0
var _spawn_cooldown := 0.0
var _spawn_count := 0
var _lane_index := 0
var _drop_carrier_spawn_count := 0


func _ready() -> void:
	reset_spawning()
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not _is_spawning_enabled:
		return

	_run_time += delta
	_spawn_cooldown -= delta
	if _spawn_cooldown > 0.0:
		return

	if _get_active_enemy_count() >= max_active_enemies:
		_spawn_cooldown = 0.35
		return

	if _spawn_next_enemy():
		_spawn_cooldown = _get_spawn_interval()
	else:
		_spawn_cooldown = 0.45


func setup(target_enemy_container: Node, target_projectile_container: Node, target_player: Node) -> void:
	enemy_container = target_enemy_container
	projectile_container = target_projectile_container
	player = target_player


func reset_spawning() -> void:
	_is_spawning_enabled = false
	_run_time = 0.0
	_spawn_cooldown = initial_spawn_delay
	_spawn_count = 0
	_lane_index = 0
	_drop_carrier_spawn_count = 0
	set_physics_process(false)


func set_spawning_enabled(should_enable: bool) -> void:
	_is_spawning_enabled = should_enable
	set_physics_process(_is_spawning_enabled)


func clear_spawned_enemies() -> void:
	if enemy_container == null:
		return

	for enemy in enemy_container.get_children():
		enemy_container.remove_child(enemy)
		enemy.queue_free()


func get_run_time() -> float:
	return _run_time


func _spawn_next_enemy() -> bool:
	if enemy_container == null:
		return false

	var enemy_type := _choose_enemy_type()
	if enemy_type.is_empty():
		return false

	var enemy_scene := _get_enemy_scene(enemy_type)
	if enemy_scene == null:
		return false

	var enemy := enemy_scene.instantiate()
	enemy_container.add_child(enemy)
	enemy.global_position = _get_spawn_position()
	_configure_enemy(enemy, enemy_type)

	_spawn_count += 1
	enemy_spawned.emit(enemy)
	return true


func _choose_enemy_type() -> String:
	var pattern := _get_spawn_pattern()
	for offset in range(pattern.size()):
		var enemy_type: String = pattern[(_spawn_count + offset) % pattern.size()]
		if _can_spawn_enemy_type(enemy_type):
			return enemy_type

	return ""


func _get_spawn_pattern() -> Array[String]:
	if _run_time < 20.0:
		return [
			ENEMY_TYPE_BASIC,
			ENEMY_TYPE_BASIC,
			ENEMY_TYPE_SHOOTER,
			ENEMY_TYPE_BASIC,
		]

	if _run_time < 45.0:
		return [
			ENEMY_TYPE_BASIC,
			ENEMY_TYPE_SHOOTER,
			ENEMY_TYPE_BASIC,
			ENEMY_TYPE_DROP_CARRIER,
			ENEMY_TYPE_BASIC,
			ENEMY_TYPE_SHOOTER,
		]

	return [
		ENEMY_TYPE_BASIC,
		ENEMY_TYPE_SHOOTER,
		ENEMY_TYPE_DROP_CARRIER,
		ENEMY_TYPE_BASIC,
		ENEMY_TYPE_SHOOTER,
		ENEMY_TYPE_SEEKER,
	]


func _get_spawn_interval() -> float:
	if _run_time < 20.0:
		return 2.4
	if _run_time < 45.0:
		return 2.0

	return 1.6


func _can_spawn_enemy_type(enemy_type: String) -> bool:
	match enemy_type:
		ENEMY_TYPE_DROP_CARRIER:
			return _get_active_drop_carrier_count() < max_active_drop_carriers
		ENEMY_TYPE_SEEKER:
			return _get_active_seeker_count() < max_active_seekers
		_:
			return true


func _get_enemy_scene(enemy_type: String) -> PackedScene:
	match enemy_type:
		ENEMY_TYPE_BASIC:
			return basic_enemy_scene
		ENEMY_TYPE_SHOOTER:
			return shooter_enemy_scene
		ENEMY_TYPE_DROP_CARRIER:
			return drop_carrier_scene
		ENEMY_TYPE_SEEKER:
			return seeker_enemy_scene
		_:
			return null


func _configure_enemy(enemy: Node, enemy_type: String) -> void:
	if enemy.has_method("set_projectile_container"):
		enemy.set_projectile_container(projectile_container)
	if enemy.has_method("set_target"):
		enemy.set_target(player)
	if enemy_type == ENEMY_TYPE_DROP_CARRIER:
		_configure_drop_carrier(enemy)
	if enemy.has_method("set_gameplay_enabled"):
		enemy.set_gameplay_enabled(_is_spawning_enabled)


func _configure_drop_carrier(enemy: Node) -> void:
	var drop_data: Dictionary = DROP_SEQUENCE[_drop_carrier_spawn_count % DROP_SEQUENCE.size()]
	_drop_carrier_spawn_count += 1
	enemy.set("drop_category", drop_data["category"])
	enemy.set("drop_id", drop_data["id"])


func _get_spawn_position() -> Vector2:
	var viewport_rect := get_viewport().get_visible_rect()
	var viewport_size := viewport_rect.size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = DESIGN_VIEWPORT_SIZE

	var min_x := viewport_rect.position.x + spawn_margin_x
	var max_x := viewport_rect.position.x + viewport_size.x - spawn_margin_x
	if min_x > max_x:
		min_x = viewport_rect.position.x + viewport_size.x * 0.5
		max_x = min_x

	var lane_count := 5
	var lane_ratio := 0.5
	if lane_count > 1:
		lane_ratio = float(_lane_index % lane_count) / float(lane_count - 1)

	_lane_index += 2
	return Vector2(lerpf(min_x, max_x, lane_ratio), viewport_rect.position.y - spawn_y_offset)


func _get_active_enemy_count() -> int:
	if enemy_container == null:
		return 0

	var count := 0
	for enemy in enemy_container.get_children():
		if not enemy.is_queued_for_deletion():
			count += 1

	return count


func _get_active_drop_carrier_count() -> int:
	if enemy_container == null:
		return 0

	var count := 0
	for enemy in enemy_container.get_children():
		if enemy is EnemyDropCarrier and not enemy.is_queued_for_deletion():
			count += 1

	return count


func _get_active_seeker_count() -> int:
	if enemy_container == null:
		return 0

	var count := 0
	for enemy in enemy_container.get_children():
		if enemy is EnemySeeker and not enemy.is_queued_for_deletion():
			count += 1

	return count
