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
const PHASE_6_TEST_PICKUPS := [
	{
		"weapon_id": "spread_shot",
		"position": Vector2(250.0, 760.0),
	},
	{
		"weapon_id": "basic_blaster",
		"position": Vector2(470.0, 760.0),
	},
]
const PHASE_7_TEST_BOOSTER := {
	"booster_id": "temporary_shield",
	"position": Vector2(360.0, 660.0),
}

@onready var trigger_game_over_button: Button = %TriggerGameOverButton
@onready var pause_menu: Control = %PauseMenu
@onready var hud: Control = %HUD
@onready var player: Node = %Player
@onready var enemy_container: Node2D = $World/EnemyContainer
@onready var projectile_container: Node2D = $World/ProjectileContainer
@onready var pickup_container: Node2D = $World/PickupContainer
@onready var score_system: Node = %ScoreSystem
@onready var spawn_manager: Node = %SpawnManager


func _ready() -> void:
	hud.pause_requested.connect(_on_pause_requested)
	trigger_game_over_button.pressed.connect(_on_trigger_game_over_button_pressed)
	pause_menu.resume_requested.connect(_on_resume_requested)
	pause_menu.main_menu_requested.connect(_on_main_menu_requested)
	score_system.score_changed.connect(hud.update_score)
	player.player_died.connect(_on_player_died)
	player.hp_changed.connect(hud.update_hp)
	player.weapon_changed.connect(hud.update_weapon)
	player.shield_changed.connect(hud.update_shield)
	player.set_projectile_container(projectile_container)
	spawn_manager.enemy_spawned.connect(_on_spawn_manager_enemy_spawned)
	spawn_manager.setup(enemy_container, projectile_container, player)
	reset_run()
	set_gameplay_enabled(false)


func set_pause_visible(should_show: bool) -> void:
	pause_menu.visible = should_show
	hud.set_pause_enabled(not should_show)
	trigger_game_over_button.disabled = should_show


func set_flow_locked(is_locked: bool) -> void:
	hud.set_pause_enabled(not is_locked)
	trigger_game_over_button.disabled = is_locked


func set_player_movement_enabled(should_enable: bool) -> void:
	player.set_movement_enabled(should_enable)


func set_player_fire_enabled(should_enable: bool) -> void:
	player.set_fire_enabled(should_enable)


func set_player_damage_enabled(should_enable: bool) -> void:
	player.set_damage_enabled(should_enable)


func set_player_pickup_collection_enabled(should_enable: bool) -> void:
	player.set_pickup_collection_enabled(should_enable)


func set_gameplay_enabled(should_enable: bool) -> void:
	set_player_movement_enabled(should_enable)
	set_player_fire_enabled(should_enable)
	set_player_damage_enabled(should_enable)
	set_player_pickup_collection_enabled(should_enable)
	set_projectiles_movement_enabled(should_enable)
	set_enemies_gameplay_enabled(should_enable)
	spawn_manager.set_spawning_enabled(should_enable)


func set_projectiles_movement_enabled(should_enable: bool) -> void:
	for projectile in projectile_container.get_children():
		if projectile.has_method("set_movement_enabled"):
			projectile.set_movement_enabled(should_enable)


func set_enemies_gameplay_enabled(should_enable: bool) -> void:
	for enemy in enemy_container.get_children():
		if enemy.has_method("set_gameplay_enabled"):
			enemy.set_gameplay_enabled(should_enable)


func clear_projectiles() -> void:
	for projectile in projectile_container.get_children():
		projectile_container.remove_child(projectile)
		projectile.queue_free()


func clear_enemies() -> void:
	for enemy in enemy_container.get_children():
		enemy_container.remove_child(enemy)
		enemy.queue_free()


func clear_pickups() -> void:
	for pickup in pickup_container.get_children():
		pickup_container.remove_child(pickup)
		pickup.queue_free()


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


func get_current_score() -> int:
	return score_system.current_score


func reset_run() -> void:
	clear_projectiles()
	clear_enemies()
	clear_pickups()
	score_system.reset_score()
	player.reset_for_run(_get_player_start_position())
	player.set_projectile_container(projectile_container)
	spawn_manager.reset_spawning()
	_spawn_phase_6_test_pickups()
	_spawn_phase_7_test_booster()


func _get_player_start_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = DESIGN_VIEWPORT_SIZE

	return Vector2(viewport_size.x * 0.5, viewport_size.y - PLAYER_START_BOTTOM_MARGIN)


func _on_pause_requested() -> void:
	pause_requested.emit()


func _on_trigger_game_over_button_pressed() -> void:
	game_over_requested.emit()


func _on_resume_requested() -> void:
	resume_requested.emit()


func _on_main_menu_requested() -> void:
	main_menu_requested.emit()


func _on_spawn_manager_enemy_spawned(enemy: Node) -> void:
	enemy.died.connect(_on_enemy_died)
	if enemy.has_signal("drop_requested"):
		enemy.drop_requested.connect(_on_enemy_drop_requested)


func _spawn_phase_6_test_pickups() -> void:
	for pickup_data in PHASE_6_TEST_PICKUPS:
		var pickup := WEAPON_PICKUP_SCENE.instantiate()
		pickup.set("weapon_id", pickup_data["weapon_id"])
		pickup_container.add_child(pickup)
		pickup.global_position = pickup_data["position"]


func _spawn_phase_7_test_booster() -> void:
	var booster := BOOSTER_PICKUP_SCENE.instantiate()
	booster.set("booster_id", PHASE_7_TEST_BOOSTER["booster_id"])
	pickup_container.add_child(booster)
	booster.global_position = PHASE_7_TEST_BOOSTER["position"]


func _on_enemy_died(score_value: int) -> void:
	score_system.add_score(score_value)


func _on_enemy_drop_requested(drop_category: String, drop_id: String, drop_position: Vector2) -> void:
	if not _is_valid_drop(drop_category, drop_id):
		push_warning("DropCarrier requested invalid drop: %s/%s" % [drop_category, drop_id])
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


func _on_player_died() -> void:
	game_over_requested.emit()
