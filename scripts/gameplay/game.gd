extends Control

signal pause_requested
signal resume_requested
signal game_over_requested
signal main_menu_requested

const DESIGN_VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const PLAYER_START_BOTTOM_MARGIN := 128.0
const WEAPON_PICKUP_SCENE := preload("res://scenes/pickups/WeaponPickup.tscn")
const BOOSTER_PICKUP_SCENE := preload("res://scenes/pickups/BoosterPickup.tscn")
const DROP_CATEGORY_WEAPON := "weapon"
const DROP_CATEGORY_BOOSTER := "booster"
const VALID_DROP_IDS := {
	DROP_CATEGORY_WEAPON: [
		"basic_blaster",
		"spread_shot",
	],
	DROP_CATEGORY_BOOSTER: [
		"temporary_shield",
	],
}
const STARTER_WEAPON_PICKUPS := [
	{
		"weapon_id": "spread_shot",
		"position": Vector2(250.0, 760.0),
	},
	{
		"weapon_id": "basic_blaster",
		"position": Vector2(470.0, 760.0),
	},
]
const STARTER_SHIELD_BOOSTER := {
	"booster_id": "temporary_shield",
	"position": Vector2(360.0, 660.0),
}
const DAMAGE_SHAKE_DURATION := 0.14
const DAMAGE_SHAKE_INTENSITY := 14.0

@onready var background: Parallax2D = %Background
@onready var world: Node2D = $World
@onready var pause_menu: Control = %PauseMenu
@onready var hud: Control = %HUD
@onready var player: Node = %Player
@onready var enemy_container: Node2D = $World/EnemyContainer
@onready var projectile_container: Node2D = $World/ProjectileContainer
@onready var pickup_container: Node2D = $World/PickupContainer
@onready var effect_container: Node2D = $World/EffectContainer
@onready var score_system: Node = %ScoreSystem
@onready var spawn_manager: Node = %SpawnManager
@onready var feedback_manager: Node = %FeedbackManager

var _audio_manager: Node
var _world_base_position := Vector2.ZERO
var _shake_time_remaining := 0.0
var _shake_duration := 0.0
var _shake_intensity := 0.0
var _screen_shake_enabled := true


func _ready() -> void:
	_world_base_position = world.position
	feedback_manager.setup(effect_container)
	feedback_manager.damage_camera_shake_requested.connect(_play_damage_camera_shake)
	hud.pause_requested.connect(_on_pause_requested)
	pause_menu.resume_requested.connect(_on_resume_requested)
	pause_menu.main_menu_requested.connect(_on_main_menu_requested)
	score_system.score_changed.connect(hud.update_score)
	player.player_died.connect(_on_player_died)
	player.hp_changed.connect(hud.update_hp)
	player.weapon_changed.connect(hud.update_weapon)
	player.shield_changed.connect(hud.update_shield)
	player.set_projectile_container(projectile_container)
	player.set_feedback_manager(feedback_manager)
	player.set_audio_manager(_audio_manager)
	spawn_manager.enemy_spawned.connect(_on_spawn_manager_enemy_spawned)
	spawn_manager.setup(enemy_container, projectile_container, player)
	if _audio_manager != null:
		feedback_manager.set_audio_manager(_audio_manager)
	reset_run()
	set_gameplay_enabled(false)


func _process(delta: float) -> void:
	_update_damage_camera_shake(delta)


func set_audio_manager(manager: Node) -> void:
	_audio_manager = manager
	if feedback_manager != null:
		feedback_manager.set_audio_manager(_audio_manager)
	if player != null:
		player.set_audio_manager(_audio_manager)
	for enemy in enemy_container.get_children():
		if enemy.has_method("set_audio_manager"):
			enemy.set_audio_manager(_audio_manager)


func set_screen_shake_enabled(should_enable: bool) -> void:
	_screen_shake_enabled = should_enable
	if not _screen_shake_enabled:
		_reset_damage_camera_shake()


func set_haptics_enabled(should_enable: bool) -> void:
	if feedback_manager != null:
		feedback_manager.set_haptics_enabled(should_enable)


func set_pause_visible(should_show: bool) -> void:
	pause_menu.visible = should_show
	hud.set_pause_enabled(not should_show)


func set_flow_locked(is_locked: bool) -> void:
	hud.set_pause_enabled(not is_locked)


func set_player_movement_enabled(should_enable: bool) -> void:
	player.set_movement_enabled(should_enable)


func set_player_fire_enabled(should_enable: bool) -> void:
	player.set_fire_enabled(should_enable)


func set_player_damage_enabled(should_enable: bool) -> void:
	player.set_damage_enabled(should_enable)


func set_player_pickup_collection_enabled(should_enable: bool) -> void:
	player.set_pickup_collection_enabled(should_enable)


func set_gameplay_enabled(should_enable: bool) -> void:
	background.set_scrolling_enabled(should_enable)
	set_player_movement_enabled(should_enable)
	set_player_fire_enabled(should_enable)
	set_player_damage_enabled(should_enable)
	set_player_pickup_collection_enabled(should_enable)
	set_projectiles_movement_enabled(should_enable)
	set_enemies_gameplay_enabled(should_enable)
	spawn_manager.set_spawning_enabled(should_enable)
	feedback_manager.set_feedback_enabled(should_enable)
	if not should_enable:
		_reset_damage_camera_shake()


func set_projectiles_movement_enabled(should_enable: bool) -> void:
	for projectile in projectile_container.get_children():
		if projectile.is_queued_for_deletion():
			continue
		if projectile.has_method("set_movement_enabled"):
			projectile.set_movement_enabled(should_enable)


func set_enemies_gameplay_enabled(should_enable: bool) -> void:
	for enemy in enemy_container.get_children():
		if enemy.has_method("set_gameplay_enabled"):
			enemy.set_gameplay_enabled(should_enable)


func clear_projectiles() -> void:
	_queue_free_container_children(projectile_container)


func clear_enemies() -> void:
	_queue_free_container_children(enemy_container)


func clear_pickups() -> void:
	_queue_free_container_children(pickup_container)


func clear_player_projectiles() -> void:
	clear_projectiles()


func clear_basic_enemies() -> void:
	clear_enemies()


func clear_player_invulnerability() -> void:
	player.clear_invulnerability()


func clear_player_shield() -> void:
	player.clear_shield()


func lock_score() -> void:
	score_system.lock_score()


func revive_run(restored_hp: int, revive_invulnerability_duration: float) -> void:
	_reset_damage_camera_shake()
	clear_projectiles()
	feedback_manager.clear_feedback()
	player.revive(_get_player_start_position(), restored_hp, revive_invulnerability_duration)
	score_system.unlock_score()


func get_current_score() -> int:
	return score_system.current_score


func reset_run() -> void:
	background.reset_scroll()
	_reset_damage_camera_shake()
	clear_projectiles()
	clear_enemies()
	clear_pickups()
	feedback_manager.clear_feedback()
	score_system.reset_score()
	player.reset_for_run(_get_player_start_position())
	player.set_projectile_container(projectile_container)
	player.set_feedback_manager(feedback_manager)
	spawn_manager.reset_spawning()
	_spawn_starter_weapon_pickups()
	_spawn_starter_shield_booster()


func _get_player_start_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = DESIGN_VIEWPORT_SIZE

	return Vector2(viewport_size.x * 0.5, viewport_size.y - PLAYER_START_BOTTOM_MARGIN)


func _on_pause_requested() -> void:
	pause_requested.emit()


func _on_resume_requested() -> void:
	resume_requested.emit()


func _on_main_menu_requested() -> void:
	main_menu_requested.emit()


func _on_spawn_manager_enemy_spawned(enemy: Node) -> void:
	if enemy.has_method("set_feedback_manager"):
		enemy.set_feedback_manager(feedback_manager)
	if enemy.has_method("set_audio_manager"):
		enemy.set_audio_manager(_audio_manager)
	enemy.died.connect(_on_enemy_died)
	if enemy.has_signal("drop_requested"):
		enemy.drop_requested.connect(_on_enemy_drop_requested)


func _spawn_starter_weapon_pickups() -> void:
	for pickup_data in STARTER_WEAPON_PICKUPS:
		var pickup := WEAPON_PICKUP_SCENE.instantiate()
		pickup.set("weapon_id", pickup_data["weapon_id"])
		pickup_container.add_child(pickup)
		pickup.global_position = pickup_data["position"]


func _spawn_starter_shield_booster() -> void:
	var booster := BOOSTER_PICKUP_SCENE.instantiate()
	booster.set("booster_id", STARTER_SHIELD_BOOSTER["booster_id"])
	pickup_container.add_child(booster)
	booster.global_position = STARTER_SHIELD_BOOSTER["position"]


func _on_enemy_died(score_value: int) -> void:
	score_system.add_score(score_value)


func _on_enemy_drop_requested(drop_category: String, drop_id: String, drop_position: Vector2) -> void:
	if not _is_valid_drop(drop_category, drop_id):
		push_warning("DropCarrier requested invalid drop: %s/%s" % [drop_category, drop_id])
		return

	call_deferred("_spawn_drop_pickup", drop_category, drop_id, drop_position)


func _spawn_drop_pickup(drop_category: String, drop_id: String, drop_position: Vector2) -> void:
	if pickup_container == null or not is_instance_valid(pickup_container):
		return

	var pickup: Node
	match drop_category:
		DROP_CATEGORY_WEAPON:
			pickup = WEAPON_PICKUP_SCENE.instantiate()
			pickup.set("weapon_id", drop_id)
		DROP_CATEGORY_BOOSTER:
			pickup = BOOSTER_PICKUP_SCENE.instantiate()
			pickup.set("booster_id", drop_id)
		_:
			return

	pickup_container.add_child(pickup)
	pickup.global_position = drop_position


func _is_valid_drop(drop_category: String, drop_id: String) -> bool:
	return VALID_DROP_IDS.has(drop_category) and VALID_DROP_IDS[drop_category].has(drop_id)


func _queue_free_container_children(container: Node) -> void:
	for child in container.get_children():
		_prepare_for_deferred_cleanup(child)
		if not child.is_queued_for_deletion():
			child.queue_free()


func _prepare_for_deferred_cleanup(node: Node) -> void:
	if node.has_method("deactivate_for_cleanup"):
		node.call("deactivate_for_cleanup")
	elif node.has_method("set_movement_enabled"):
		node.call("set_movement_enabled", false)
	elif node.has_method("set_gameplay_enabled"):
		node.call("set_gameplay_enabled", false)

	if node is CanvasItem:
		(node as CanvasItem).visible = false


func _on_player_died() -> void:
	game_over_requested.emit()


func _play_damage_camera_shake() -> void:
	if not _screen_shake_enabled:
		return

	_shake_duration = DAMAGE_SHAKE_DURATION
	_shake_time_remaining = DAMAGE_SHAKE_DURATION
	_shake_intensity = DAMAGE_SHAKE_INTENSITY


func _update_damage_camera_shake(delta: float) -> void:
	if _shake_time_remaining <= 0.0:
		return

	_shake_time_remaining = maxf(_shake_time_remaining - delta, 0.0)
	if _shake_time_remaining <= 0.0:
		_reset_damage_camera_shake()
		return

	var decay := _shake_time_remaining / _shake_duration
	var offset := Vector2(
		randf_range(-_shake_intensity, _shake_intensity),
		randf_range(-_shake_intensity, _shake_intensity)
	) * decay
	world.position = _world_base_position + offset


func _reset_damage_camera_shake() -> void:
	_shake_time_remaining = 0.0
	_shake_duration = 0.0
	_shake_intensity = 0.0
	if world != null:
		world.position = _world_base_position
