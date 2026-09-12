extends Control

const MAIN_MENU_SCENE := preload("res://scenes/ui/MainMenu.tscn")
const GAME_SCENE := preload("res://scenes/gameplay/Game.tscn")
const TUTORIAL_SCENE := preload("res://scenes/gameplay/TutorialLevel.tscn")
const GAME_OVER_SCENE := preload("res://scenes/ui/GameOverScreen.tscn")
const GAME_STATE_MANAGER_SCRIPT := preload("res://scripts/core/game_state_manager.gd")
const SAVE_DATA_SCRIPT := preload("res://scripts/systems/save_data.gd")
const REVIVE_HP := 3
const REVIVE_INVULNERABILITY_DURATION := 2.0

@onready var game_state_manager: Node = $GameStateManager
@onready var audio_manager: Node = $AudioManager
@onready var ads_manager: Node = $AdsManager

var main_menu: Control
var game: Control
var tutorial: Control
var game_over_screen: Control
var save_data
var revive_used_this_run := false

var _revive_attempted_at_current_game_over := false
var _pending_final_score := -1
var _run_score_finalized := false


func _ready() -> void:
	save_data = SAVE_DATA_SCRIPT.new()
	save_data.load_data()
	audio_manager.apply_settings(save_data.get_settings())
	ads_manager.rewarded_ready_changed.connect(_on_rewarded_ready_changed)
	ads_manager.rewarded_session_finished.connect(_on_rewarded_session_finished)
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
		KEY_R:
			if game_state_manager.current_state == GAME_STATE_MANAGER_SCRIPT.State.GAME_OVER:
				_restart_run()
		KEY_M:
			if game_state_manager.current_state in [GAME_STATE_MANAGER_SCRIPT.State.PAUSED, GAME_STATE_MANAGER_SCRIPT.State.GAME_OVER]:
				_return_to_main_menu()


func _show_main_menu() -> void:
	_clear_tutorial()
	_clear_game()
	_clear_game_over()
	_clear_main_menu()

	main_menu = MAIN_MENU_SCENE.instantiate()
	add_child(main_menu)
	main_menu.set_best_score(save_data.get_best_score())
	main_menu.set_settings(save_data.get_settings())
	main_menu.start_requested.connect(_start_run)
	main_menu.tutorial_requested.connect(_start_tutorial)
	main_menu.settings_button_pressed.connect(_on_main_menu_settings_button_pressed)
	main_menu.settings_back_pressed.connect(_on_main_menu_settings_back_pressed)
	main_menu.setting_changed.connect(_on_main_menu_setting_changed)
	ads_manager.show_main_menu_banner()
	audio_manager.play_menu_bgm()


func _start_run(play_button_sfx := true) -> void:
	_clear_tutorial()
	if play_button_sfx:
		audio_manager.play_button_sfx()
	ads_manager.hide_banner()
	revive_used_this_run = false
	_revive_attempted_at_current_game_over = false
	_pending_final_score = -1
	_run_score_finalized = false
	_clear_main_menu()
	_clear_game_over()

	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.STARTING_RUN)
	game = GAME_SCENE.instantiate()
	add_child(game)
	var settings: Dictionary = save_data.get_settings()
	game.set_audio_manager(audio_manager)
	game.set_screen_shake_enabled(bool(settings.get("screen_shake_enabled", true)))
	game.set_haptics_enabled(bool(settings.get("haptics_enabled", true)))
	game.pause_requested.connect(_pause_run)
	game.resume_requested.connect(_resume_run)
	game.game_over_requested.connect(_trigger_game_over)
	game.main_menu_requested.connect(_return_to_main_menu)
	game.set_pause_visible(false)
	game.set_flow_locked(false)
	game.set_gameplay_enabled(false)
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.PLAYING)
	game.set_gameplay_enabled(game_state_manager.is_gameplay_allowed())
	ads_manager.preload_rewarded_revive_ad()
	audio_manager.play_gameplay_bgm()


func _start_tutorial() -> void:
	audio_manager.play_button_sfx()
	ads_manager.hide_banner()
	_clear_main_menu()
	_clear_tutorial()
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.TUTORIAL)
	tutorial = TUTORIAL_SCENE.instantiate()
	add_child(tutorial)
	tutorial.set_audio_manager(audio_manager)
	tutorial.main_menu_requested.connect(_return_from_tutorial_to_main_menu)
	tutorial.start_run_requested.connect(_start_run)
	audio_manager.play_gameplay_bgm()


func _return_from_tutorial_to_main_menu() -> void:
	audio_manager.play_button_sfx()
	_clear_tutorial()
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.RETURNING_TO_MENU)
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.MAIN_MENU)
	_show_main_menu()


func _clear_tutorial() -> void:
	if tutorial != null:
		var old_tutorial := tutorial
		tutorial = null
		remove_child(old_tutorial)
		old_tutorial.queue_free()


func _pause_run() -> void:
	if game == null:
		return

	audio_manager.play_pause_sfx()
	audio_manager.pause_gameplay_bgm()
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.PAUSED)
	game.set_gameplay_enabled(false)
	game.set_pause_visible(true)


func _resume_run() -> void:
	if game == null:
		return

	audio_manager.play_resume_sfx()
	game.set_pause_visible(false)
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.PLAYING)
	game.set_gameplay_enabled(game_state_manager.is_gameplay_allowed())
	audio_manager.resume_gameplay_bgm()


func _trigger_game_over() -> void:
	if game == null or game_state_manager.current_state == GAME_STATE_MANAGER_SCRIPT.State.GAME_OVER:
		return

	var final_score: int = game.get_current_score()
	_pending_final_score = final_score
	_revive_attempted_at_current_game_over = false
	var did_set_new_best: bool = final_score > save_data.get_best_score()
	if revive_used_this_run:
		did_set_new_best = _finalize_run_score(final_score)
	var best_score: int = maxi(save_data.get_best_score(), final_score)
	_clear_game_over()
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.GAME_OVER)
	ads_manager.hide_banner()
	game.lock_score()
	game.set_gameplay_enabled(false)
	game.clear_player_invulnerability()
	game.clear_player_shield()
	game.clear_projectiles()
	game.set_pause_visible(false)
	game.set_flow_locked(true)

	game_over_screen = GAME_OVER_SCENE.instantiate()
	add_child(game_over_screen)
	game_over_screen.set_scores(final_score, best_score, did_set_new_best)
	game_over_screen.restart_requested.connect(_restart_run)
	game_over_screen.main_menu_requested.connect(_return_to_main_menu)
	game_over_screen.revive_requested.connect(_on_revive_requested)
	_refresh_revive_availability()


func _restart_run() -> void:
	audio_manager.play_button_sfx()
	_finalize_pending_run_score()
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.RESTARTING)
	_clear_game()
	_clear_game_over()
	_start_run(false)


func _return_to_main_menu() -> void:
	audio_manager.play_button_sfx()
	_finalize_pending_run_score()
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.RETURNING_TO_MENU)
	_clear_game()
	_clear_game_over()
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.MAIN_MENU)
	_show_main_menu()


func _on_main_menu_settings_button_pressed() -> void:
	audio_manager.play_button_sfx()


func _on_main_menu_settings_back_pressed() -> void:
	audio_manager.play_button_sfx()


func _on_main_menu_setting_changed(setting_name: String, value: bool) -> void:
	save_data.set_setting(setting_name, value)
	var settings: Dictionary = save_data.get_settings()
	audio_manager.apply_settings(settings)
	if game != null:
		game.set_haptics_enabled(bool(settings.get("haptics_enabled", true)))
		game.set_screen_shake_enabled(bool(settings.get("screen_shake_enabled", true)))
	_restore_bgm_for_current_state()


func _on_revive_requested() -> void:
	if game == null or game_over_screen == null:
		return
	if game_state_manager.current_state != GAME_STATE_MANAGER_SCRIPT.State.GAME_OVER:
		return
	if revive_used_this_run or _revive_attempted_at_current_game_over:
		return
	if not ads_manager.is_rewarded_revive_ready():
		_refresh_revive_availability()
		return

	_revive_attempted_at_current_game_over = true
	game_over_screen.set_revive_state(false, false, "OPENING REWARD AD...")
	audio_manager.play_button_sfx()
	audio_manager.pause_for_fullscreen_ad()
	if not ads_manager.show_rewarded_revive_ad():
		audio_manager.resume_after_fullscreen_ad()
		game_over_screen.set_revive_state(false, false, "AD UNAVAILABLE")


func _on_rewarded_ready_changed(_is_ready: bool) -> void:
	_refresh_revive_availability()


func _on_rewarded_session_finished(did_earn_reward: bool) -> void:
	audio_manager.resume_after_fullscreen_ad()
	if not did_earn_reward:
		if game_over_screen != null:
			game_over_screen.set_revive_state(false, false, "REWARD NOT EARNED")
		return

	if game == null or game_state_manager.current_state != GAME_STATE_MANAGER_SCRIPT.State.GAME_OVER:
		return
	if revive_used_this_run:
		return

	revive_used_this_run = true
	_pending_final_score = -1
	_clear_game_over()
	game.revive_run(REVIVE_HP, REVIVE_INVULNERABILITY_DURATION)
	game.set_pause_visible(false)
	game.set_flow_locked(false)
	game_state_manager.transition_to(GAME_STATE_MANAGER_SCRIPT.State.PLAYING)
	game.set_gameplay_enabled(game_state_manager.is_gameplay_allowed())


func _refresh_revive_availability() -> void:
	if game_over_screen == null:
		return

	if revive_used_this_run:
		game_over_screen.set_revive_state(false, true, "")
		return
	if _revive_attempted_at_current_game_over:
		return

	var can_revive: bool = ads_manager.is_rewarded_revive_ready()
	var status_text := ""
	if not can_revive:
		status_text = "LOADING REWARD AD..." if ads_manager.is_rewarded_loading() else "AD UNAVAILABLE"
	game_over_screen.set_revive_state(can_revive, false, status_text)


func _finalize_pending_run_score() -> void:
	if _pending_final_score < 0 or _run_score_finalized:
		return
	_finalize_run_score(_pending_final_score)


func _finalize_run_score(final_score: int) -> bool:
	if _run_score_finalized:
		return false
	_run_score_finalized = true
	return save_data.submit_score(final_score)


func _restore_bgm_for_current_state() -> void:
	var settings: Dictionary = save_data.get_settings()
	if not bool(settings.get("music_enabled", true)):
		return

	if game_state_manager.current_state == GAME_STATE_MANAGER_SCRIPT.State.MAIN_MENU:
		audio_manager.play_menu_bgm()
	elif game_state_manager.current_state in [
		GAME_STATE_MANAGER_SCRIPT.State.PLAYING,
		GAME_STATE_MANAGER_SCRIPT.State.PAUSED,
		GAME_STATE_MANAGER_SCRIPT.State.GAME_OVER,
		GAME_STATE_MANAGER_SCRIPT.State.STARTING_RUN,
		GAME_STATE_MANAGER_SCRIPT.State.RESTARTING,
	]:
		audio_manager.play_gameplay_bgm()


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
		if old_game.has_method("prepare_for_scene_disposal"):
			old_game.call("prepare_for_scene_disposal")
		remove_child(old_game)
		old_game.queue_free()


func _clear_game_over() -> void:
	if game_over_screen != null:
		var old_game_over_screen := game_over_screen
		game_over_screen = null
		remove_child(old_game_over_screen)
		old_game_over_screen.queue_free()
