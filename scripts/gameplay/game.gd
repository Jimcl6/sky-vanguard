extends Control

signal pause_requested
signal resume_requested
signal game_over_requested

const DESIGN_VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const PLAYER_START_BOTTOM_MARGIN := 128.0
const ENEMY_BASIC_SCENE := preload("res://scenes/enemies/EnemyBasic.tscn")
const PHASE_4_TEST_ENEMY_POSITIONS := [
	Vector2(360.0, 260.0),
	Vector2(260.0, 420.0),
	Vector2(460.0, 420.0),
]

@onready var pause_button: Button = %PauseButton
@onready var trigger_game_over_button: Button = %TriggerGameOverButton
@onready var pause_menu: Control = %PauseMenu
@onready var hud: Control = %HUD
@onready var player: Node = %Player
@onready var enemy_container: Node2D = $World/EnemyContainer
@onready var projectile_container: Node2D = $World/ProjectileContainer
@onready var score_system: Node = %ScoreSystem


func _ready() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)
	trigger_game_over_button.pressed.connect(_on_trigger_game_over_button_pressed)
	pause_menu.resume_requested.connect(_on_resume_requested)
	score_system.score_changed.connect(hud.update_score)
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


func set_gameplay_enabled(should_enable: bool) -> void:
	set_player_movement_enabled(should_enable)
	set_player_fire_enabled(should_enable)
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


func clear_player_projectiles() -> void:
	for projectile in projectile_container.get_children():
		projectile.queue_free()


func clear_basic_enemies() -> void:
	for enemy in enemy_container.get_children():
		enemy.queue_free()


func lock_score() -> void:
	score_system.lock_score()


func reset_run() -> void:
	clear_player_projectiles()
	clear_basic_enemies()
	score_system.reset_score()
	player.reset_for_run(_get_player_start_position())
	player.set_projectile_container(projectile_container)
	_spawn_phase_4_test_enemies()


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


func _spawn_phase_4_test_enemies() -> void:
	for spawn_position in PHASE_4_TEST_ENEMY_POSITIONS:
		var enemy := ENEMY_BASIC_SCENE.instantiate()
		enemy_container.add_child(enemy)
		enemy.global_position = spawn_position
		enemy.died.connect(_on_basic_enemy_died)
		if enemy.has_method("set_gameplay_enabled"):
			enemy.set_gameplay_enabled(false)


func _on_basic_enemy_died(score_value: int) -> void:
	score_system.add_score(score_value)
