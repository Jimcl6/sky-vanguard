extends Node
class_name FeedbackManager

const HIT_FLASH_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const PLAYER_DAMAGE_COLOR := Color(1.0, 0.2, 0.18, 1.0)
const SHIELD_COLOR := Color(0.46, 0.93, 1.0, 0.95)
const WEAPON_PICKUP_COLOR := Color(0.39, 1.0, 0.58, 0.95)
const BOOSTER_PICKUP_COLOR := Color(0.48, 0.92, 1.0, 0.95)
const DEATH_COLOR := Color(1.0, 0.62, 0.24, 0.95)
const MISSILE_DESTROYED_COLOR := Color(1.0, 0.34, 0.22, 0.95)

var effect_container: Node2D
var _is_feedback_enabled := false


func setup(target_effect_container: Node2D) -> void:
	effect_container = target_effect_container


func set_feedback_enabled(should_enable: bool) -> void:
	_is_feedback_enabled = should_enable
	if not _is_feedback_enabled:
		clear_feedback()


func clear_feedback() -> void:
	if effect_container == null:
		return

	for effect in effect_container.get_children():
		effect_container.remove_child(effect)
		effect.queue_free()


func play_player_damage(player: Node) -> void:
	if not _can_play():
		return

	_flash_child(player, "Visual", PLAYER_DAMAGE_COLOR, 0.12)
	_spawn_ring(player.global_position, PLAYER_DAMAGE_COLOR, 36.0, 0.18)
	_play_player_damage_audio()


func play_player_death(position: Vector2) -> void:
	if not _can_play():
		return

	_spawn_cross(position, PLAYER_DAMAGE_COLOR, 42.0, 0.22)


func play_shield_activate(player: Node) -> void:
	if not _can_play():
		return

	_pulse_child(player, "ShieldVisual", 1.16, 0.18)
	_spawn_ring(player.global_position, SHIELD_COLOR, 48.0, 0.2)


func play_shield_absorb(player: Node) -> void:
	if not _can_play():
		return

	_pulse_child(player, "ShieldVisual", 1.22, 0.16)
	_spawn_ring(player.global_position, SHIELD_COLOR, 54.0, 0.18)
	_play_shield_absorb_audio()


func play_enemy_hit(enemy: Node) -> void:
	if not _can_play():
		return

	_flash_child(enemy, "Visual", HIT_FLASH_COLOR, 0.08)
	_flash_child(enemy, "CoreVisual", HIT_FLASH_COLOR, 0.08)
	_spawn_ring(enemy.global_position, HIT_FLASH_COLOR, 24.0, 0.12)


func play_enemy_destroyed(position: Vector2) -> void:
	if not _can_play():
		return

	_spawn_cross(position, DEATH_COLOR, 36.0, 0.2)
	_play_enemy_destroyed_audio()


func play_weapon_pickup_collected(position: Vector2, _weapon_id: String) -> void:
	if not _can_play():
		return

	_spawn_diamond(position, WEAPON_PICKUP_COLOR, 34.0, 0.2)
	_play_pickup_audio()


func play_booster_pickup_collected(position: Vector2, _booster_id: String) -> void:
	if not _can_play():
		return

	_spawn_ring(position, BOOSTER_PICKUP_COLOR, 42.0, 0.2)
	_play_pickup_audio()


func play_homing_missile_destroyed(position: Vector2) -> void:
	if not _can_play():
		return

	_spawn_cross(position, MISSILE_DESTROYED_COLOR, 30.0, 0.16)


func _can_play() -> bool:
	return _is_feedback_enabled and effect_container != null


func _flash_child(owner: Node, child_name: String, flash_color: Color, duration: float) -> void:
	var child := owner.get_node_or_null(child_name)
	if not child is Polygon2D:
		return

	var visual := child as Polygon2D
	var original_color := visual.color
	visual.color = flash_color

	var tween := visual.create_tween()
	tween.tween_property(visual, "color", original_color, duration)


func _pulse_child(owner: Node, child_name: String, scale_amount: float, duration: float) -> void:
	var child := owner.get_node_or_null(child_name)
	if not child is Node2D:
		return

	var visual := child as Node2D
	var original_scale := visual.scale
	var tween := visual.create_tween()
	tween.tween_property(visual, "scale", original_scale * scale_amount, duration * 0.45)
	tween.tween_property(visual, "scale", original_scale, duration * 0.55)


func _spawn_ring(position: Vector2, color: Color, radius: float, duration: float) -> void:
	var points := PackedVector2Array()
	var point_count := 16
	for index in range(point_count):
		var angle := TAU * float(index) / float(point_count)
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	_spawn_line_effect(position, points, color, 4.0, duration, 1.35, true)


func _spawn_diamond(position: Vector2, color: Color, radius: float, duration: float) -> void:
	var points := PackedVector2Array([
		Vector2(0.0, -radius),
		Vector2(radius, 0.0),
		Vector2(0.0, radius),
		Vector2(-radius, 0.0),
	])
	_spawn_line_effect(position, points, color, 4.0, duration, 1.28, true)


func _spawn_cross(position: Vector2, color: Color, radius: float, duration: float) -> void:
	var points := PackedVector2Array([
		Vector2(-radius, 0.0),
		Vector2(radius, 0.0),
		Vector2.ZERO,
		Vector2(0.0, -radius),
		Vector2(0.0, radius),
	])
	_spawn_line_effect(position, points, color, 5.0, duration, 1.18, false)


func _spawn_line_effect(position: Vector2, points: PackedVector2Array, color: Color, width: float, duration: float, scale_amount: float, is_closed: bool) -> void:
	if effect_container == null:
		return

	var effect := Line2D.new()
	effect.width = width
	effect.default_color = color
	effect.closed = is_closed
	effect.points = points
	effect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	effect_container.add_child(effect)
	effect.global_position = position

	var tween := effect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "scale", Vector2.ONE * scale_amount, duration)
	tween.tween_property(effect, "modulate:a", 0.0, duration)
	tween.chain().tween_callback(effect.queue_free)


func _play_player_damage_audio() -> void:
	pass


func _play_shield_absorb_audio() -> void:
	pass


func _play_enemy_destroyed_audio() -> void:
	pass


func _play_pickup_audio() -> void:
	pass
