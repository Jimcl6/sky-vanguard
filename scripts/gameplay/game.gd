extends Control

signal pause_requested
signal resume_requested
signal game_over_requested

const DESIGN_VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const PLAYER_START_BOTTOM_MARGIN := 128.0
const ENEMY_BASIC_SCENE := preload("res://scenes/enemies/EnemyBasic.tscn")
const ENEMY_SHOOTER_SCENE := preload("res://scenes/enemies/EnemyShooter.tscn")
const WEAPON_PICKUP_SCENE := preload("res://scenes/pickups/WeaponPickup.tscn")
const PHASE_5_BASIC_TEST_ENEMY_POSITIONS := [
	Vector2(360.0, 260.0),
	Vector2(250.0, 430.0),
]
const PHASE_5_SHOOTER_TEST_ENEMY_POSITIONS := [
	Vector2(470.0, 310.0),
	Vector2(360.0, 560.0),
]
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

@onready var pause_button: Button = %PauseButton
@onready var trigger_game_over_button: Button = %TriggerGameOverButton
@onready var pause_menu: Control = %PauseMenu
@onready var hud: Control = %HUD
@onready var player: Node = %Player
@onready var enemy_container: Node2D = $World/EnemyContainer
@onready var projectile_container: Node2D = $World/ProjectileContainer
@onready var pickup_container: Node2D = $World/PickupContainer
@onready var score_system: Node = %ScoreSystem


func _ready() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)
	trigger_game_over_button.pressed.connect(_on_trigger_game_over_button_pressed)
	pause_menu.resume_requested.connect(_on_resume_requested)
	score_system.score_changed.connect(hud.update_score)
	player.player_died.connect(_on_player_died)
	player.hp_changed.connect(hud.update_hp)
	player.weapon_changed.connect(hud.update_weapon)
	player.set_projectile_container(projectile_container)
	reset_run()
	set_gameplay_enabled(false)


func set_pause_visible(should_show: bool) -> void:
	pause_menu.visible = should_show
	pause_button.disabled = should_show
	trigger_game_over_button.disabled = should_show


func set_flow_locked(is_locked: bool) -> void:
	pause_button.disabled = is_locked
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


func lock_score() -> void:
	score_system.lock_score()


func reset_run() -> void:
	clear_projectiles()
	clear_enemies()
	clear_pickups()
	score_system.reset_score()
	player.reset_for_run(_get_player_start_position())
	player.set_projectile_container(projectile_container)
	_spawn_phase_5_test_enemies()
	_spawn_phase_6_test_pickups()


func _get_player_start_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = DESIGN_VIEWPORT_SIZE

	return Vector2(viewport_size.x * 0.5, viewport_size.y - PLAYER_START_BOTTOM_MARGIN)


func _on_pause_button_pressed() -> void:
	pause_requested.emit()


func _on_trigger_game_over_button_pressed() -> void:
	game_over_requested.emit()


func _on_resume_requested() -> void:
	resume_requested.emit()


func _spawn_phase_5_test_enemies() -> void:
	for spawn_position in PHASE_5_BASIC_TEST_ENEMY_POSITIONS:
		_spawn_enemy(ENEMY_BASIC_SCENE, spawn_position)

	for spawn_position in PHASE_5_SHOOTER_TEST_ENEMY_POSITIONS:
		_spawn_enemy(ENEMY_SHOOTER_SCENE, spawn_position)


func _spawn_enemy(enemy_scene: PackedScene, spawn_position: Vector2) -> void:
	var enemy := enemy_scene.instantiate()
	enemy_container.add_child(enemy)
	enemy.global_position = spawn_position
	enemy.died.connect(_on_enemy_died)
	if enemy.has_method("set_projectile_container"):
		enemy.set_projectile_container(projectile_container)
	if enemy.has_method("set_gameplay_enabled"):
		enemy.set_gameplay_enabled(false)


func _spawn_phase_6_test_pickups() -> void:
	for pickup_data in PHASE_6_TEST_PICKUPS:
		var pickup := WEAPON_PICKUP_SCENE.instantiate()
		pickup.set("weapon_id", pickup_data["weapon_id"])
		pickup_container.add_child(pickup)
		pickup.global_position = pickup_data["position"]


func _on_enemy_died(score_value: int) -> void:
	score_system.add_score(score_value)


func _on_player_died() -> void:
	game_over_requested.emit()
