extends Control

signal pause_requested
signal resume_requested
signal game_over_requested

const DESIGN_VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const PLAYER_START_BOTTOM_MARGIN := 128.0

@onready var pause_button: Button = %PauseButton
@onready var trigger_game_over_button: Button = %TriggerGameOverButton
@onready var pause_menu: Control = %PauseMenu
@onready var player: Node = %Player
@onready var projectile_container: Node2D = $World/ProjectileContainer


func _ready() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)
	trigger_game_over_button.pressed.connect(_on_trigger_game_over_button_pressed)
	pause_menu.resume_requested.connect(_on_resume_requested)
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


func set_projectiles_movement_enabled(should_enable: bool) -> void:
	for projectile in projectile_container.get_children():
		if projectile.has_method("set_movement_enabled"):
			projectile.set_movement_enabled(should_enable)


func clear_player_projectiles() -> void:
	for projectile in projectile_container.get_children():
		projectile.queue_free()


func reset_run() -> void:
	clear_player_projectiles()
	player.reset_for_run(_get_player_start_position())
	player.set_projectile_container(projectile_container)


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
