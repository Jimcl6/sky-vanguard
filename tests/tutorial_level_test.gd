extends SceneTree

var failures := 0
var capture := false


func _initialize() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	call_deferred("_run")


func _run() -> void:
	for viewport_size in [Vector2i(720, 1280), Vector2i(720, 1600)]:
		root.size = viewport_size
		var main = load("res://scenes/core/Main.tscn").instantiate()
		root.add_child(main)
		await process_frame
		await process_frame
		var saved_best: int = main.save_data.get_best_score()
		await _snapshot("menu_%d" % viewport_size.y)
		main.main_menu.get_node("%TutorialButton").pressed.emit()
		await process_frame
		await process_frame
		var tutorial = main.tutorial
		_check(tutorial != null and main.game == null, "Tutorial has no normal game")
		_check(main.game_state_manager.get_state_name() == "TUTORIAL", "Tutorial state")
		_check(not main.game_state_manager.is_gameplay_allowed(), "Normal gameplay remains gated")
		_check(not tutorial.player.can_receive_damage, "Tutorial damage disabled")
		_check(not tutorial.player.pickup_collector.monitoring, "Tutorial pickups disabled")
		_check(not tutorial.player.weapon_controller.can_fire, "Tutorial fire disabled")
		await _snapshot("touch_%d" % viewport_size.y)
		_touch(Vector2(360, 500), true)
		await process_frame
		_check(tutorial.step == 0, "Distant touch cannot pass first lesson")
		_touch(Vector2(360, 500), false)
		_touch(tutorial.player.position, true)
		await process_frame
		_check(tutorial.step == 1, "Real touch near ship advances")
		await _snapshot("move_%d" % viewport_size.y)
		for expected_step in range(1, 6):
			_check(tutorial.step == expected_step, "Correct movement lesson")
			var drag := InputEventScreenDrag.new()
			drag.index = 0
			drag.position = tutorial.target
			root.push_input(drag)
			for frame in range(100):
				await physics_frame
				await process_frame
				if tutorial.step != expected_step:
					break
			_check(tutorial.step == expected_step + 1, "Drag reaches marker")
		_touch(tutorial.player.position, false)
		_check(tutorial.step == 6, "Reached pause lesson")
		# An automatic background pause must not satisfy the pause-button lesson.
		tutorial.set_paused(true, false)
		tutorial.set_paused(false)
		_check(tutorial.step == 6, "Focus loss does not finish lesson")
		await process_frame
		_click(tutorial._pause_button)
		await process_frame
		_check(tutorial.paused, "Pause button receives input")
		_check(not tutorial.player.can_move and tutorial.background.autoscroll == Vector2.ZERO, "Pause freezes movement and ocean")
		var position_before: Vector2 = tutorial.player.position
		_touch(position_before, true)
		await physics_frame
		_check(tutorial.player.position == position_before, "Paused touches cannot move ship")
		_touch(position_before, false)
		await _snapshot("pause_%d" % viewport_size.y)
		_click(tutorial._pause_menu.get_node("%ResumeButton"))
		await process_frame
		_check(tutorial.step == 7 and not tutorial.paused, "Resume completes lesson")
		await _snapshot("complete_%d" % viewport_size.y)
		if viewport_size.y == 1600:
			_click(tutorial._completion.get_child(1))
			await process_frame
			_check(main.tutorial == null and main.main_menu != null, "Completion returns to menu")
			_click(main.main_menu.get_node("%StartButton"))
		else:
			_click(tutorial._completion.get_child(0))
		await process_frame
		_check(main.tutorial == null and main.game != null, "Play Run clears tutorial")
		_check(main.game_state_manager.is_gameplay_allowed(), "Run starts normally")
		_check(main.game.get_current_score() == 0, "Run starts with zero score")
		main._pause_run()
		_check(not main.game.get_node("%Player").can_move, "Normal pause still freezes player")
		main._resume_run()
		main._trigger_game_over()
		_check(main.game_over_screen != null, "Normal Game Over opens")
		main._restart_run()
		_check(main.game.get_current_score() == 0, "Normal restart clears score")
		main._return_to_main_menu()
		await process_frame
		main.main_menu.get_node("%TutorialButton").pressed.emit()
		await process_frame
		_check(main.tutorial.step == 0, "Reentry resets tutorial")
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT
		mouse.position = main.tutorial.player.position
		mouse.pressed = true
		root.push_input(mouse)
		await process_frame
		_check(main.tutorial.step == 1, "Desktop mouse starts training")
		mouse.pressed = false
		root.push_input(mouse)
		main.tutorial.set_paused(true)
		main.tutorial._pause_menu.main_menu_requested.emit()
		await process_frame
		_check(main.tutorial == null and main.main_menu != null, "Pause exit clears tutorial")
		_check(main.save_data.get_best_score() == saved_best, "Tutorial preserves best score")
		main.audio_manager.apply_settings({"music_enabled": false, "sound_enabled": false})
		await create_timer(0.1).timeout
		main.queue_free()
		await process_frame
	await create_timer(0.1).timeout
	print("TUTORIAL_TEST failures=", failures)
	quit(failures)


func _touch(position: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = pressed
	root.push_input(event)


func _click(button: Button) -> void:
	var position := button.get_global_rect().get_center()
	_touch(position, true)
	_touch(position, false)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _snapshot(label: String) -> void:
	await process_frame
	await process_frame
	if capture:
		await RenderingServer.frame_post_draw
		var path := "user://tutorial_%s.png" % label
		root.get_texture().get_image().save_png(path)
		print(ProjectSettings.globalize_path(path))
