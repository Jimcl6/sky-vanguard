extends SceneTree

const PLAYER_PROJECTILE_SCENE := preload("res://scenes/projectiles/PlayerProjectile.tscn")
const ENEMY_PROJECTILE_SCENE := preload("res://scenes/projectiles/EnemyProjectile.tscn")
const HOMING_MISSILE_SCENE := preload("res://scenes/projectiles/HomingMissile.tscn")
const WEAPON_PICKUP_SCENE := preload("res://scenes/pickups/WeaponPickup.tscn")
const BOOSTER_PICKUP_SCENE := preload("res://scenes/pickups/BoosterPickup.tscn")

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func fixture() -> SpawnManager:
	var manager := SpawnManager.new()
	root.add_child(manager)
	var enemies := Node2D.new()
	manager.add_child(enemies)
	manager.setup(enemies, null, null)
	return manager

func clear(manager: SpawnManager) -> void:
	for enemy in manager.enemy_container.get_children():
		enemy.free()


func free_container_children(container: Node) -> void:
	for child in container.get_children():
		child.free()


func old_node_is_gone_or_detached(node: Variant) -> bool:
	return not is_instance_valid(node) or node.is_queued_for_deletion() or not node.is_inside_tree()

func trace_run(seed_value: int) -> Array:
	var manager := fixture()
	manager.reset_spawning(seed_value)
	manager.set_spawning_enabled(true)
	var trace: Array = []
	var last_x := INF
	for tick in range(18000):
		# Simulate ten minutes, retaining enemies for six seconds to exercise caps.
		for enemy in manager.enemy_container.get_children():
			enemy.position.y += 180.0 / 30.0
			if enemy.position.y > 1000.0:
				enemy.free()
		var count_before := manager._spawn_count
		manager._physics_process(1.0 / 30.0)
		if manager._spawn_count != count_before:
			var enemy: Node2D = manager.enemy_container.get_child(-1)
			var kind := manager._last_enemy_type
			var t := manager.get_run_time()
			check(manager._spawn_count == count_before + 1, "No catch-up bursts")
			check(enemy.position.x >= 84.0 and enemy.position.x <= 636.0, "Safe x bounds")
			check(absf(enemy.position.x - last_x) >= 70.0, "Successive x spacing")
			check(enemy.position.y == -72.0, "Above-screen entry")
			check(t >= 20.0 or kind in ["basic", "shooter"], "No early carriers")
			check(t >= 45.0 or kind != "seeker", "No early seekers")
			check(count_before >= 2 or kind == "basic", "Basic opening")
			var base := 2.4 if t < 20.0 else (2.0 if t < 45.0 else 1.6)
			check(manager._spawn_cooldown >= base * 0.85 and manager._spawn_cooldown <= base * 1.15, "Timing bounds")
			check(manager._get_active_enemy_count() <= 8, "Total cap")
			check(manager._get_active_drop_carrier_count() <= 1, "Carrier cap")
			check(manager._get_active_seeker_count() <= 1, "Seeker cap")
			trace.append([kind, enemy.position.x, t, manager._spawn_cooldown])
			last_x = enemy.position.x
	check(trace.size() > 300, "Long run never stalls")
	manager.free()
	return trace

func _run() -> void:
	root.size = Vector2i(720, 1280)
	var first := trace_run(123)
	check(first == trace_run(123), "Identical seed and inputs reproduce trace")
	for seed_value in range(5):
		check(first != trace_run(seed_value), "Different seeds vary trace")
	var m := fixture()
	m.reset_spawning(42)
	m.set_spawning_enabled(true)
	m._physics_process(0.99)
	check(m._spawn_count == 0, "Initial delay")
	m._physics_process(0.02)
	check(m._spawn_count == 1, "First spawn after one second")
	var state := m._rng.state
	var cooldown := m._spawn_cooldown
	var run_time := m._run_time
	var pool := m._spawn_pool.duplicate()
	m.set_spawning_enabled(false)
	m._physics_process(100.0)
	check(m._rng.state == state and m._spawn_cooldown == cooldown and m._run_time == run_time and m._spawn_pool == pool, "Disabled spawning freezes all state")
	m.set_spawning_enabled(true)
	m._physics_process(100.0)
	check(m._spawn_count <= 2, "Large delta cannot burst")
	clear(m)
	m.reset_spawning(42)
	m._run_time = 45.0
	m._refresh_spawn_pool()
	check(m._spawn_pool.count("basic") == 2 and m._spawn_pool.count("shooter") == 2 and m._spawn_pool.count("seeker") == 1 and m._spawn_pool.count("drop_carrier") == 1, "Late pool ratios")
	m._run_time = 20.0
	m._refresh_spawn_pool()
	check(m._spawn_pool.count("basic") == 3 and m._spawn_pool.count("shooter") == 2 and m._spawn_pool.count("drop_carrier") == 1 and not m._spawn_pool.has("seeker"), "Middle pool ratios")
	m.reset_spawning(42)
	m._refresh_spawn_pool()
	check(m._spawn_pool.count("basic") == 3 and m._spawn_pool.count("shooter") == 1, "Opening pool ratios")
	# Block the complete entry width with stationary obstacles.
	for x in range(84, 637, 80):
		var obstacle := Node2D.new()
		m.enemy_container.add_child(obstacle)
		obstacle.position = Vector2(x, -72)
	m.set_spawning_enabled(true)
	m._physics_process(1.0)
	var pending := m._pending_type
	pool = m._spawn_pool.duplicate()
	check(m._spawn_count == 0 and is_equal_approx(m._spawn_cooldown, 0.35), "Crowding retries without spawning")
	m._physics_process(0.36)
	check(m._pending_type == pending and m._spawn_pool == pool, "Retry retains pending choice and pool")
	clear(m)
	m._physics_process(0.36)
	check(m._spawn_count == 1 and m._last_enemy_type == pending, "Retry succeeds after clearance")
	clear(m)
	m._run_time = 45.0
	m._refresh_spawn_pool()
	m._spawn_count = 10
	m._spawn_pool.assign(["seeker", "drop_carrier"])
	m.max_active_seekers = 0
	m.max_active_drop_carriers = 0
	pool = m._spawn_pool.duplicate()
	check(m._spawn_next_enemy() and m._last_enemy_type == "basic" and m._spawn_pool == pool, "Blocked special pool falls back without consuming")
	clear(m)
	m.max_active_seekers = 1
	m.max_active_drop_carriers = 1
	check(m._spawn_next_enemy() and m._last_enemy_type in ["seeker", "drop_carrier"], "Special resumes when cap permits")
	clear(m)
	m._spawn_pool.assign(["shooter", "basic"])
	m._last_enemy_type = "shooter"
	check(m._spawn_next_enemy() and m._last_enemy_type == "basic", "Avoid consecutive shooter when alternative exists")
	clear(m)
	m.max_active_enemies = 0
	m.set_spawning_enabled(true)
	m._spawn_cooldown = 0.0
	var before := m._spawn_count
	m._physics_process(1.0)
	check(m._spawn_count == before, "Full cap blocks spawning")
	m.spawn_margin_x = 400.0
	check(m._get_spawn_position().x == 360.0, "Collapsed width uses center")
	state = m._rng.seed
	m.reset_spawning()
	check(m._rng.seed != state and m._run_time == 0.0 and m._spawn_count == 0 and m._spawn_pool.is_empty() and m._pending_type.is_empty() and m._last_spawn_x == INF, "Fresh run resets history and seed")
	m.free()
	# Exercise the actual Game integration, including the existing revive path.
	var game = load("res://scenes/gameplay/Game.tscn").instantiate()
	root.add_child(game)
	game.reset_run()
	game.set_gameplay_enabled(true)
	var gm: SpawnManager = game.spawn_manager
	gm._physics_process(1.1)
	state = gm._rng.state
	cooldown = gm._spawn_cooldown
	run_time = gm._run_time
	pool = gm._spawn_pool.duplicate()
	game.set_gameplay_enabled(false)
	gm._physics_process(60.0)
	game.revive_run(3, 2.0)
	check(gm._rng.state == state and gm._spawn_cooldown == cooldown and gm._run_time == run_time and gm._spawn_pool == pool, "Game pause/death/revive preserves spawn state")
	game.set_gameplay_enabled(true)
	check(gm._is_spawning_enabled, "Game resume enables spawning")
	game.reset_run()
	await process_frame
	check(gm._run_time == 0.0 and gm._spawn_count == 0 and game.enemy_container.get_child_count() == 0, "Game restart clears run and enemies")
	game.free()
	await process_frame
	await _check_main_restart_after_revive_cleanup()
	if failures.is_empty():
		print("SPAWN_RANDOMIZATION_PASS checks=", checks, " simulated_runs=7 minutes_per_run=10")
	else:
		for failure in failures:
			push_error(failure)
	await process_frame
	quit(0 if failures.is_empty() else 1)


func _check_main_restart_after_revive_cleanup() -> void:
	var main = load("res://scenes/core/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.audio_manager.apply_settings({"music_enabled": false, "sound_enabled": false})
	main._start_run(false)
	await process_frame

	var old_game = main.game
	var old_manager: SpawnManager = old_game.spawn_manager
	old_manager.reset_spawning(9001)
	old_manager._run_time = 45.0
	old_manager._spawn_count = 10
	old_manager._refresh_spawn_pool()
	old_game.set_gameplay_enabled(true)
	old_manager._spawn_next_enemy()
	free_container_children(old_game.enemy_container)
	old_manager._spawn_next_enemy()
	var old_enemy_refs: Array[Node] = []
	old_enemy_refs.assign(old_game.enemy_container.get_children())

	var weapon_pickup := WEAPON_PICKUP_SCENE.instantiate()
	weapon_pickup.set("weapon_id", "spread_shot")
	old_game.pickup_container.add_child(weapon_pickup)
	weapon_pickup.global_position = Vector2(160.0, 860.0)
	var booster_pickup := BOOSTER_PICKUP_SCENE.instantiate()
	booster_pickup.set("booster_id", "temporary_shield")
	old_game.pickup_container.add_child(booster_pickup)
	booster_pickup.global_position = Vector2(560.0, 820.0)
	old_game._on_enemy_drop_requested("weapon", "basic_blaster", Vector2(360.0, 520.0))
	var old_pickup_refs: Array[Node] = []
	old_pickup_refs.assign(old_game.pickup_container.get_children())

	var player_projectile := PLAYER_PROJECTILE_SCENE.instantiate()
	old_game.projectile_container.add_child(player_projectile)
	player_projectile.global_position = Vector2(360.0, 800.0)
	var enemy_projectile := ENEMY_PROJECTILE_SCENE.instantiate()
	enemy_projectile.configure(Vector2.DOWN, 1.0, 5.0, 1)
	old_game.projectile_container.add_child(enemy_projectile)
	enemy_projectile.global_position = Vector2(300.0, 700.0)
	var homing_missile := HOMING_MISSILE_SCENE.instantiate()
	homing_missile.configure(old_game.player, Vector2.DOWN)
	old_game.projectile_container.add_child(homing_missile)
	homing_missile.global_position = Vector2(420.0, 700.0)
	var old_projectile_refs: Array[Node] = []
	old_projectile_refs.assign(old_game.projectile_container.get_children())

	var old_run_time := old_manager._run_time
	var old_spawn_count := old_manager._spawn_count
	main._trigger_game_over()
	await process_frame
	main._on_rewarded_session_finished(true)
	await process_frame
	check(main.revive_used_this_run, "Restart regression setup consumes revive")
	check(old_game.player.current_hp == 3, "Restart regression setup revives with HP 3")
	check(old_manager._run_time >= old_run_time and old_manager._spawn_count >= old_spawn_count, "Rewarded revive keeps spawn progress before restart")

	main._trigger_game_over()
	await process_frame
	check(main.game_over_screen != null, "Second death returns to Game Over before restart")
	check(main.revive_used_this_run, "Second death keeps revive unavailable before restart")
	main._restart_run()
	var new_game = main.game
	new_game.set_player_fire_enabled(false)
	check(new_game != null and new_game != old_game, "Restart replaces Game instance after revive")
	check(main.revive_used_this_run == false, "Restart resets revive availability")
	check(new_game.get_current_score() == 0, "Restart-after-revive resets score")
	check(new_game.player.current_hp == new_game.player.max_hp, "Restart-after-revive restores HP 5")
	check(new_game.player.weapon_controller.get_current_weapon_id() == "basic_blaster", "Restart-after-revive restores Basic Blaster")
	check(new_game.spawn_manager._run_time == 0.0 and new_game.spawn_manager._spawn_count == 0, "Restart-after-revive resets spawn timeline")
	check(new_game.enemy_container.get_child_count() == 0, "Restart-after-revive has no old enemies in new run")
	check(new_game.projectile_container.get_child_count() == 0, "Restart-after-revive has no old projectiles or missiles in new run")
	check(new_game.pickup_container.get_child_count() == 3, "Restart-after-revive has only starter pickups")
	for frame in range(4):
		await process_frame

	for old_enemy in old_enemy_refs:
		check(old_node_is_gone_or_detached(old_enemy), "Old enemy is gone or detached after restart")
	for old_pickup in old_pickup_refs:
		check(old_node_is_gone_or_detached(old_pickup), "Old pickup is gone or detached after restart")
	for old_projectile in old_projectile_refs:
		check(old_node_is_gone_or_detached(old_projectile), "Old projectile or missile is gone or detached after restart")

	var restarted_manager: SpawnManager = new_game.spawn_manager
	restarted_manager.reset_spawning(12345)
	free_container_children(new_game.enemy_container)
	check(restarted_manager._spawn_next_enemy() and restarted_manager._last_enemy_type == "basic", "First post-restart enemy is Basic")
	free_container_children(new_game.enemy_container)
	check(restarted_manager._spawn_next_enemy() and restarted_manager._last_enemy_type == "basic", "Second post-restart enemy is Basic")

	main.queue_free()
	await process_frame
