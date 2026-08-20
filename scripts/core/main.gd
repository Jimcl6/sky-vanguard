extends Control

const MAIN_MENU_SCENE := preload("res://scenes/ui/MainMenu.tscn")
const GAME_SCENE := preload("res://scenes/gameplay/Game.tscn")
const GAME_OVER_SCENE := preload("res://scenes/ui/GameOverScreen.tscn")
const GAME_STATE_MANAGER_SCRIPT := preload("res://scripts/core/game_state_manager.gd")

@onready var game_state_manager: Node = $GameStateManager

var main_menu: Control
var game: Control
var game_over_screen: Control


func _ready() -> void:
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.MAIN_MENU)
	_show_main_menu()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	match key_event.keycode:
		KEY_ESCAPE:
			if game_state_manager.current_state == GAME_STATE_MANAGER_SCRIPT.State.PLAYING:
				_pause_run()
			elif game_state_manager.current_state == GAME_STATE_MANAGER_SCRIPT.State.PAUSED:
				_resume_run()
		KEY_G:
			if game_state_manager.current_state == GAME_STATE_MANAGER_SCRIPT.State.PLAYING:
				_trigger_game_over()
		KEY_R:
			if game_state_manager.current_state == GAME_STATE_MANAGER_SCRIPT.State.GAME_OVER:
				_restart_run()
		KEY_M:
			if game_state_manager.current_state in [GAME_STATE_MANAGER_SCRIPT.State.PAUSED, GAME_STATE_MANAGER_SCRIPT.State.GAME_OVER]:
				_return_to_main_menu()


func _show_main_menu() -> void:
	_clear_game()
	_clear_game_over()
	_clear_main_menu()

	main_menu = MAIN_MENU_SCENE.instantiate()
	add_child(main_menu)
	main_menu.start_requested.connect(_start_run)


func _start_run() -> void:
	_clear_main_menu()
	_clear_game_over()

	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.STARTING_RUN)
	game = GAME_SCENE.instantiate()
	add_child(game)
	game.pause_requested.connect(_pause_run)
	game.resume_requested.connect(_resume_run)
	game.game_over_requested.connect(_trigger_game_over)
	game.main_menu_requested.connect(_return_to_main_menu)
	game.set_pause_visible(false)
	game.set_flow_locked(false)
	game.reset_run()
	game.set_gameplay_enabled(false)
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.PLAYING)
	game.set_gameplay_enabled(game_state_manager.is_gameplay_allowed())


func _pause_run() -> void:
	if game == null:
		return

	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.PAUSED)
	game.set_gameplay_enabled(false)
	game.set_pause_visible(true)


func _resume_run() -> void:
	if game == null:
		return

	game.set_pause_visible(false)
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.PLAYING)
	game.set_gameplay_enabled(game_state_manager.is_gameplay_allowed())


func _trigger_game_over() -> void:
	if game == null:
		return

	var final_score: int = game.get_current_score()
	_clear_game_over()
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.GAME_OVER)
	game.lock_score()
	game.set_gameplay_enabled(false)
	game.clear_player_invulnerability()
	game.clear_player_shield()
	game.clear_projectiles()
	game.clear_enemies()
	game.clear_pickups()
	game.set_pause_visible(false)
	game.set_flow_locked(true)

	game_over_screen = GAME_OVER_SCENE.instantiate()
	add_child(game_over_screen)
	game_over_screen.set_final_score(final_score)
	game_over_screen.restart_requested.connect(_restart_run)
	game_over_screen.main_menu_requested.connect(_return_to_main_menu)


func _restart_run() -> void:
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.RESTARTING)
	_clear_game()
	_clear_game_over()
	_start_run()


func _return_to_main_menu() -> void:
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.RETURNING_TO_MENU)
	_clear_game()
	_clear_game_over()
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.MAIN_MENU)
	_show_main_menu()


func _clear_main_menu() -> void:
	if main_menu != null:
		var old_main_menu := main_menu
		main_menu = null
		remove_child(old_main_menu)
		old_main_menu.queue_free()


func _clear_game() -> void:
	if game != null:
		var old_game := game
		game = null
		remove_child(old_game)
		old_game.queue_free()


func _clear_game_over() -> void:
	if game_over_screen != null:
		var old_game_over_screen := game_over_screen
		game_over_screen = null
		remove_child(old_game_over_screen)
		old_game_over_screen.queue_free()
