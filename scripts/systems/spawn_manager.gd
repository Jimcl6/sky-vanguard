extends Node
class_name SpawnManager

signal enemy_spawned(enemy: Node)

const ENEMY_TYPE_BASIC := "basic"
const ENEMY_TYPE_SHOOTER := "shooter"
const ENEMY_TYPE_DROP_CARRIER := "drop_carrier"
const ENEMY_TYPE_SEEKER := "seeker"
const DESIGN_VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const POSITION_ATTEMPTS := 8
const SUCCESSIVE_SPAWN_DISTANCE := 70.0
const ENTRY_CLEARANCE := 100.0
const RETRY_DELAY := 0.35
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
var _drop_carrier_spawn_count := 0
var _rng := RandomNumberGenerator.new()
var _spawn_pool: Array[String] = []
var _pool_stage := -1
var _pending_type := ""
var _pending_pool_index := -1
var _last_enemy_type := ""
var _last_spawn_x := INF


func _ready() -> void:
	reset_spawning()
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not _is_spawning_enabled:
		return

	_run_time += delta
	_refresh_spawn_pool()
	_spawn_cooldown -= delta
	if _spawn_cooldown > 0.0:
		return

	if _get_active_enemy_count() >= max_active_enemies:
		_spawn_cooldown = RETRY_DELAY
		return

	if _spawn_next_enemy():
		_spawn_cooldown = _get_spawn_interval()
	else:
		_spawn_cooldown = RETRY_DELAY


func setup(target_enemy_container: Node, target_projectile_container: Node, target_player: Node) -> void:
	enemy_container = target_enemy_container
	projectile_container = target_projectile_container
	player = target_player


func reset_spawning(run_seed: int = -1) -> void:
	_is_spawning_enabled = false
	_run_time = 0.0
	_spawn_cooldown = initial_spawn_delay
	_spawn_count = 0
	_drop_carrier_spawn_count = 0
	if run_seed == -1:
		_rng.randomize()
	else:
		_rng.seed = run_seed
	_spawn_pool.clear()
	_pool_stage = -1
	_pending_type = ""
	_pending_pool_index = -1
	_last_enemy_type = ""
	_last_spawn_x = INF
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
	var spawn_position := _get_spawn_position()
	if not spawn_position.is_finite():
		return false

	var enemy := enemy_scene.instantiate()
	enemy_container.add_child(enemy)
	enemy.global_position = spawn_position
	_configure_enemy(enemy, enemy_type)

	if _pending_pool_index >= 0:
		_spawn_pool.remove_at(_pending_pool_index)
	_pending_type = ""
	_pending_pool_index = -1
	_last_enemy_type = enemy_type
	_last_spawn_x = spawn_position.x
	_spawn_count += 1
	enemy_spawned.emit(enemy)
	return true


func _choose_enemy_type() -> String:
	_refresh_spawn_pool()
	if not _pending_type.is_empty() and _can_spawn_enemy_type(_pending_type):
		return _pending_type
	_pending_pool_index = -1
	var eligible: Array[int] = []
	var alternatives: Array[int] = []
	for index in range(_spawn_pool.size()):
		var enemy_type := _spawn_pool[index]
		if not _can_spawn_enemy_type(enemy_type):
			continue
		if _spawn_count < 2 and enemy_type != ENEMY_TYPE_BASIC:
			continue
		eligible.append(index)
		if enemy_type != ENEMY_TYPE_SHOOTER:
			alternatives.append(index)
	if _last_enemy_type == ENEMY_TYPE_SHOOTER and not alternatives.is_empty():
		eligible = alternatives
	if eligible.is_empty():
		# Keep capped special enemies in the pool until they can enter safely.
		_pending_type = ENEMY_TYPE_BASIC
	else:
		_pending_pool_index = eligible[_rng.randi_range(0, eligible.size() - 1)]
		_pending_type = _spawn_pool[_pending_pool_index]
	return _pending_type


func _refresh_spawn_pool() -> void:
	var stage := 0 if _run_time < 20.0 else (1 if _run_time < 45.0 else 2)
	if stage != _pool_stage:
		_pool_stage = stage
		_spawn_pool.clear()
		_pending_type = ""
		_pending_pool_index = -1
	if _spawn_pool.is_empty():
		_spawn_pool = _get_spawn_pattern()


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
	var base_interval := 1.6
	if _run_time < 20.0:
		base_interval = 2.4
	elif _run_time < 45.0:
		base_interval = 2.0
	return base_interval * _rng.randf_range(0.85, 1.15)


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

	# Reduce the history gap only for unusually narrow viewports to avoid deadlock.
	var history_gap := minf(SUCCESSIVE_SPAWN_DISTANCE, (max_x - min_x) * 0.5)
	for attempt in range(POSITION_ATTEMPTS):
		var candidate := Vector2(_rng.randf_range(min_x, max_x), viewport_rect.position.y - spawn_y_offset)
		if absf(candidate.x - _last_spawn_x) < history_gap:
			continue
		if _is_entry_clear(candidate):
			return candidate
	return Vector2(INF, INF)


func _is_entry_clear(candidate: Vector2) -> bool:
	if enemy_container == null:
		return true
	for enemy in enemy_container.get_children():
		if enemy is Node2D and not enemy.is_queued_for_deletion():
			if candidate.distance_to(enemy.global_position) < ENTRY_CLEARANCE:
				return false
	return true


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
