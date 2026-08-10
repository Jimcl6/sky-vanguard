extends Area2D
class_name EnemyBasic

signal died(score_value: int)

const OFFSCREEN_MARGIN := 96.0

@export var max_hp := 2
@export var speed := 120.0
@export var score_value := 100

var current_hp := 0
var can_move := true
var can_receive_damage := true

var _is_dead := false


func _ready() -> void:
	reset_health()
	set_physics_process(can_move)


func _physics_process(delta: float) -> void:
	if not can_move:
		return

	global_position.y += speed * delta

	if _is_below_viewport():
		queue_free()


func set_gameplay_enabled(should_enable: bool) -> void:
	can_move = should_enable
	can_receive_damage = should_enable
	set_physics_process(can_move)


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


func _die() -> void:
	if _is_dead:
		return

	_is_dead = true
	can_move = false
	can_receive_damage = false
	died.emit(score_value)
	queue_free()


func _is_below_viewport() -> bool:
	var viewport_rect := get_viewport_rect()
	return global_position.y > viewport_rect.position.y + viewport_rect.size.y + OFFSCREEN_MARGIN
