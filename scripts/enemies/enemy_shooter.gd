extends Area2D
class_name EnemyShooter

signal died(score_value: int)

const OFFSCREEN_MARGIN := 96.0
const ENEMY_PROJECTILE_SCENE := preload("res://scenes/projectiles/EnemyProjectile.tscn")

@export var max_hp := 3
@export var speed := 90.0
@export var score_value := 150
@export var fire_interval := 1.6
@export var projectile_speed := 520.0
@export var projectile_lifetime := 5.0
@export var projectile_damage := 1

@onready var fire_point: Marker2D = $FirePoint

var current_hp := 0
var can_move := true
var can_receive_damage := true
var can_fire := true
var projectile_container: Node

var _fire_cooldown := 0.0
var _is_dead := false


func _ready() -> void:
	reset_health()
	_fire_cooldown = fire_interval * 0.5
	set_physics_process(can_move or can_fire)


func _physics_process(delta: float) -> void:
	if can_move:
		global_position.y += speed * delta

	if can_fire:
		_fire_cooldown -= delta
		if _fire_cooldown <= 0.0:
			_fire_enemy_projectile()
			_fire_cooldown = fire_interval

	if _is_below_viewport():
		queue_free()


func set_projectile_container(container: Node) -> void:
	projectile_container = container


func set_gameplay_enabled(should_enable: bool) -> void:
	can_move = should_enable
	can_receive_damage = should_enable
	can_fire = should_enable
	set_physics_process(can_move or can_fire)


func reset_health() -> void:
	current_hp = max_hp
	_is_dead = false
	can_receive_damage = true


func take_damage(amount: int) -> bool:
	if amount <= 0 or _is_dead or not can_receive_damage:
		return false

	current_hp = maxi(current_hp - amount, 0)

	if current_hp == 0:
		_die()

	return true


func _fire_enemy_projectile() -> void:
	if projectile_container == null:
		return

	var projectile := ENEMY_PROJECTILE_SCENE.instantiate()
	projectile_container.add_child(projectile)
	projectile.global_position = fire_point.global_position

	if projectile.has_method("configure"):
		projectile.configure(Vector2.DOWN, projectile_speed, projectile_lifetime, projectile_damage)


func _die() -> void:
	if _is_dead:
		return

	_is_dead = true
	can_move = false
	can_receive_damage = false
	can_fire = false
	died.emit(score_value)
	queue_free()


func _is_below_viewport() -> bool:
	var viewport_rect := get_viewport_rect()
	return global_position.y > viewport_rect.position.y + viewport_rect.size.y + OFFSCREEN_MARGIN
