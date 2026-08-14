extends Node2D
class_name WeaponController

signal weapon_changed(weapon_id: String, display_name: String)

const WEAPON_BASIC_BLASTER := "basic_blaster"
const WEAPON_SPREAD_SHOT := "spread_shot"
const WEAPON_DISPLAY_NAMES := {
	WEAPON_BASIC_BLASTER: "Basic Blaster",
	WEAPON_SPREAD_SHOT: "Spread Shot",
}
const PLAYER_PROJECTILE_SCENE := preload("res://scenes/projectiles/PlayerProjectile.tscn")

@export var basic_blaster_fire_interval := 0.32
@export var spread_shot_fire_interval := 0.52
@export var projectile_speed := 1100.0
@export var projectile_lifetime := 3.0
@export var muzzle_offset := Vector2(0.0, -42.0)
@export var spread_shot_angle_degrees := 14.0

var current_weapon_id := WEAPON_BASIC_BLASTER
var can_fire := false
var projectile_container: Node

var _fire_cooldown := 0.0


func _ready() -> void:
	reset_weapon()
	set_physics_process(can_fire)


func _physics_process(delta: float) -> void:
	if not can_fire:
		return

	_fire_cooldown -= delta
	if _fire_cooldown > 0.0:
		return

	_fire_current_weapon()
	_fire_cooldown = _get_current_fire_interval()


func set_projectile_container(container: Node) -> void:
	projectile_container = container


func set_fire_enabled(should_enable: bool) -> void:
	can_fire = should_enable and projectile_container != null
	set_physics_process(can_fire)

	if can_fire:
		_fire_cooldown = 0.0


func reset_weapon() -> void:
	current_weapon_id = WEAPON_BASIC_BLASTER
	_fire_cooldown = 0.0
	weapon_changed.emit(current_weapon_id, get_current_weapon_display_name())


func set_weapon(weapon_id: String) -> bool:
	if not is_valid_weapon_id(weapon_id):
		return false

	if current_weapon_id == weapon_id:
		_fire_cooldown = 0.0
		return true

	current_weapon_id = weapon_id
	_fire_cooldown = 0.0
	weapon_changed.emit(current_weapon_id, get_current_weapon_display_name())
	return true


func get_current_weapon_id() -> String:
	return current_weapon_id


func get_current_weapon_display_name() -> String:
	return get_weapon_display_name(current_weapon_id)


static func is_valid_weapon_id(weapon_id: String) -> bool:
	return WEAPON_DISPLAY_NAMES.has(weapon_id)


static func get_weapon_display_name(weapon_id: String) -> String:
	if not WEAPON_DISPLAY_NAMES.has(weapon_id):
		return "Unknown Weapon"

	return WEAPON_DISPLAY_NAMES[weapon_id]


func _fire_current_weapon() -> void:
	match current_weapon_id:
		WEAPON_SPREAD_SHOT:
			_fire_spread_shot()
		_:
			_fire_basic_blaster()


func _get_current_fire_interval() -> float:
	match current_weapon_id:
		WEAPON_SPREAD_SHOT:
			return spread_shot_fire_interval
		_:
			return basic_blaster_fire_interval


func _fire_basic_blaster() -> void:
	_spawn_player_projectile(Vector2.UP, global_position + muzzle_offset)


func _fire_spread_shot() -> void:
	var angle_radians := deg_to_rad(spread_shot_angle_degrees)
	_spawn_player_projectile(Vector2.UP.rotated(-angle_radians), global_position + muzzle_offset)
	_spawn_player_projectile(Vector2.UP, global_position + muzzle_offset)
	_spawn_player_projectile(Vector2.UP.rotated(angle_radians), global_position + muzzle_offset)


func _spawn_player_projectile(direction: Vector2, spawn_position: Vector2) -> void:
	if projectile_container == null:
		return

	var projectile := PLAYER_PROJECTILE_SCENE.instantiate()
	projectile_container.add_child(projectile)
	projectile.global_position = spawn_position

	if projectile.has_method("configure"):
		projectile.configure(direction, projectile_speed, projectile_lifetime)
