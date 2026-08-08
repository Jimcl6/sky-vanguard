extends Node2D
class_name Player

signal player_died

@export var move_speed := 1200.0
@export var max_hp := 3
@export var bounds_margin := Vector2(48.0, 64.0)
@export var start_bottom_margin := 128.0
@export var touch_radius := 88.0

@onready var weapon_controller: Node = $WeaponController

var current_hp: int = 3
var can_move := false
var active_touch_id := -1
var touch_offset := Vector2.ZERO

var _target_position := Vector2.ZERO
var _mouse_dragging := false


func _ready() -> void:
	reset_health()
	_target_position = global_position


func _physics_process(delta: float) -> void:
	if not can_move:
		return

	global_position = global_position.move_toward(_target_position, move_speed * delta)
	global_position = _clamp_to_play_area(global_position)


func _input(event: InputEvent) -> void:
	if not can_move:
		return

	if event is InputEventScreenDrag and event.index == active_touch_id:
		_handle_screen_drag(event)
	elif event is InputEventScreenTouch and not event.pressed and event.index == active_touch_id:
		_handle_screen_touch(event)
	elif event is InputEventMouseMotion and _mouse_dragging:
		_handle_mouse_motion(event)
	elif event is InputEventMouseButton and not event.pressed and _mouse_dragging:
		_handle_mouse_button(event)


func _unhandled_input(event: InputEvent) -> void:
	if not can_move:
		return

	if event is InputEventScreenTouch and event.pressed:
		_handle_screen_touch(event)
	elif event is InputEventMouseButton and event.pressed:
		_handle_mouse_button(event)


func set_movement_enabled(should_enable: bool) -> void:
	can_move = should_enable

	if not can_move:
		_release_drag()
		_target_position = global_position


func set_projectile_container(container: Node) -> void:
	weapon_controller.set_projectile_container(container)


func set_fire_enabled(should_enable: bool) -> void:
	weapon_controller.set_fire_enabled(should_enable)


func reset_weapon_system() -> void:
	weapon_controller.reset_weapon()


func reset_for_run(start_position: Variant = null) -> void:
	reset_health()
	_release_drag()
	reset_weapon_system()

	var resolved_start_position := get_default_start_position()
	if start_position is Vector2:
		resolved_start_position = start_position

	global_position = _clamp_to_play_area(resolved_start_position)
	_target_position = global_position


func reset_health() -> void:
	current_hp = max_hp


func take_damage(amount: int) -> void:
	if amount <= 0 or current_hp <= 0:
		return

	current_hp = int(clamp(current_hp - amount, 0, max_hp))

	if current_hp == 0:
		player_died.emit()


func get_default_start_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	return Vector2(viewport_size.x * 0.5, viewport_size.y - start_bottom_margin)


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _is_touch_start_allowed(event.position):
			active_touch_id = event.index
			touch_offset = global_position - event.position
			_set_target_from_pointer(event.position)
			get_viewport().set_input_as_handled()
	elif event.index == active_touch_id:
		_release_drag()
		get_viewport().set_input_as_handled()


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index != active_touch_id:
		return

	_set_target_from_pointer(event.position)
	get_viewport().set_input_as_handled()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.pressed:
		if _is_touch_start_allowed(event.position):
			_mouse_dragging = true
			touch_offset = global_position - event.position
			_set_target_from_pointer(event.position)
			get_viewport().set_input_as_handled()
	else:
		if _mouse_dragging:
			_release_drag()
			get_viewport().set_input_as_handled()


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if not _mouse_dragging:
		return

	_set_target_from_pointer(event.position)
	get_viewport().set_input_as_handled()


func _set_target_from_pointer(pointer_position: Vector2) -> void:
	_target_position = _clamp_to_play_area(pointer_position + touch_offset)


func _release_drag() -> void:
	active_touch_id = -1
	touch_offset = Vector2.ZERO
	_mouse_dragging = false


func _is_touch_start_allowed(pointer_position: Vector2) -> bool:
	return pointer_position.distance_to(global_position) <= touch_radius


func _clamp_to_play_area(value: Vector2) -> Vector2:
	var viewport_rect := get_viewport_rect()
	var min_x := viewport_rect.position.x + bounds_margin.x
	var max_x := viewport_rect.position.x + viewport_rect.size.x - bounds_margin.x
	var min_y := viewport_rect.position.y + bounds_margin.y
	var max_y := viewport_rect.position.y + viewport_rect.size.y - bounds_margin.y

	if min_x > max_x:
		value.x = viewport_rect.position.x + viewport_rect.size.x * 0.5
	else:
		value.x = clampf(value.x, min_x, max_x)

	if min_y > max_y:
		value.y = viewport_rect.position.y + viewport_rect.size.y * 0.5
	else:
		value.y = clampf(value.y, min_y, max_y)

	return value
