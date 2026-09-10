extends SceneTree

const MAIN_SCENE := preload("res://scenes/core/Main.tscn")
const PLAYER_PROJECTILE_SCENE := preload("res://scenes/projectiles/PlayerProjectile.tscn")
const ENEMY_PROJECTILE_SCENE := preload("res://scenes/projectiles/EnemyProjectile.tscn")
const HOMING_MISSILE_SCENE := preload("res://scenes/projectiles/HomingMissile.tscn")

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(720, 1280)
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	main._start_run(false)
	await process_frame
	await physics_frame
	var game: Control = main.game
	game.set_player_fire_enabled(false)

	_spawn_background_projectiles(game)
	var lethal_projectile := ENEMY_PROJECTILE_SCENE.instantiate()
	lethal_projectile.configure(Vector2.DOWN, 1.0, 5.0, game.player.max_hp)
	game.projectile_container.add_child(lethal_projectile)
	lethal_projectile.global_position = game.player.global_position

	for _frame in range(6):
		await physics_frame
		await process_frame
		if main.game_over_screen != null:
			break

	_check(main.game_over_screen != null, "Physics collision opens Game Over")
	_check(game.projectile_container.get_child_count() == 0, "Death clears every projectile")

	var revive_cleanup_nodes := _spawn_background_projectiles(game)
	main._on_rewarded_session_finished(true)
	game.set_player_fire_enabled(false)
	_check(main.revive_used_this_run, "Rewarded callback consumes the one revive")
	_check(game.player.current_hp == 3, "Rewarded revive restores 3 HP")
	for projectile in revive_cleanup_nodes:
		_check(projectile.is_queued_for_deletion(), "Revive queues projectile cleanup")
		_check(not projectile.can_move, "Queued projectile remains inactive")
	game.clear_projectiles()
	game.clear_projectiles()
	await process_frame
	_check(game.projectile_container.get_child_count() == 0, "Repeated revive cleanup is idempotent")

	game.clear_player_invulnerability()
	var second_lethal_projectile := ENEMY_PROJECTILE_SCENE.instantiate()
	second_lethal_projectile.configure(Vector2.DOWN, 1.0, 5.0, game.player.max_hp)
	game.projectile_container.add_child(second_lethal_projectile)
	second_lethal_projectile.global_position = game.player.global_position
	for _frame in range(6):
		await physics_frame
		await process_frame
		if main.game_over_screen != null:
			break

	_check(main.game_over_screen != null, "Second physics collision opens Game Over")
	_check(main.revive_used_this_run, "Second death preserves one-revive limit")
	_check(game.projectile_container.get_child_count() == 0, "Second death clears every projectile")

	main._restart_run()
	await process_frame
	await process_frame
	_check(main.game != null and main.game != game, "Restart creates a clean game instance")
	_check(main.game.get_current_score() == 0, "Restart resets score")
	_check(main.game.player.current_hp == main.game.player.max_hp, "Restart restores full HP")
	_check(main.game.player.weapon_controller.get_current_weapon_id() == "basic_blaster", "Restart restores Basic Blaster")

	main.audio_manager.apply_settings({"music_enabled": false, "sound_enabled": false})
	main.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("COLLISION_CLEANUP_TEST failures=", failures)
	quit(failures)


func _spawn_background_projectiles(game: Control) -> Array[Node]:
	var projectiles: Array[Node] = []
	var player_projectile := PLAYER_PROJECTILE_SCENE.instantiate()
	game.projectile_container.add_child(player_projectile)
	player_projectile.global_position = Vector2(100.0, 200.0)
	projectiles.append(player_projectile)

	var enemy_projectile := ENEMY_PROJECTILE_SCENE.instantiate()
	enemy_projectile.configure(Vector2.DOWN, 1.0, 5.0, 1)
	game.projectile_container.add_child(enemy_projectile)
	enemy_projectile.global_position = Vector2(620.0, 200.0)
	projectiles.append(enemy_projectile)

	var homing_missile := HOMING_MISSILE_SCENE.instantiate()
	homing_missile.configure(game.player, Vector2.DOWN)
	game.projectile_container.add_child(homing_missile)
	homing_missile.global_position = Vector2(100.0, 300.0)
	projectiles.append(homing_missile)
	return projectiles


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
