extends Node2D
class_name WeaponController

const BASIC_BLASTER_NAME := "Basic Blaster"
const PLAYER_PROJECTILE_SCENE := preload("res://scenes/projectiles/PlayerProjectile.tscn")

@export var basic_blaster_fire_interval := 0.32
@export var projectile_speed := 1100.0
@export var projectile_lifetime := 3.0
@export var muzzle_offset := Vector2(0.0, -42.0)

var current_weapon_name := BASIC_BLASTER_NAME
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

	_fire_basic_blaster()
	_fire_cooldown = basic_blaster_fire_interval


func set_projectile_container(container: Node) -> void:
	projectile_container = container


func set_fire_enabled(should_enable: bool) -> void:
	can_fire = should_enable and projectile_container != null
	set_physics_process(can_fire)

	if can_fire:
		_fire_cooldown = 0.0


func reset_weapon() -> void:
	current_weapon_name = BASIC_BLASTER_NAME
	_fire_cooldown = 0.0


func _fire_basic_blaster() -> void:
	if projectile_container == null:
		return

	var projectile := PLAYER_PROJECTILE_SCENE.instantiate()
	projectile_container.add_child(projectile)
	projectile.global_position = global_position + muzzle_offset

	if projectile.has_method("configure"):
		projectile.configure(Vector2.UP, projectile_speed, projectile_lifetime)
