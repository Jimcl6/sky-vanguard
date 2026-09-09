extends RefCounted
class_name SafeAreaLayout

const EMPTY_RECT := Rect2i()


static func get_safe_area_info(viewport: Viewport) -> Dictionary:
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(720.0, 1280.0))
	if viewport != null:
		viewport_rect = viewport.get_visible_rect()

	var viewport_size := viewport_rect.size
	var window_size_i := DisplayServer.window_get_size()
	var window_size := Vector2(float(window_size_i.x), float(window_size_i.y))
	if window_size.x <= 0.0 or window_size.y <= 0.0:
		window_size = viewport_size

	var physical_safe_area := DisplayServer.get_display_safe_area()
	if physical_safe_area == EMPTY_RECT:
		physical_safe_area = Rect2i(Vector2i.ZERO, window_size_i)

	var scale := Vector2.ONE
	if window_size.x > 0.0 and window_size.y > 0.0:
		scale = Vector2(viewport_size.x / window_size.x, viewport_size.y / window_size.y)

	var project_safe_area := _physical_rect_to_project_rect(physical_safe_area, scale, viewport_rect.position)
	project_safe_area = project_safe_area.intersection(viewport_rect)
	if project_safe_area.size.x <= 0.0 or project_safe_area.size.y <= 0.0:
		project_safe_area = viewport_rect

	var project_cutouts: Array[Rect2] = []
	for cutout in DisplayServer.get_display_cutouts():
		project_cutouts.append(_physical_rect_to_project_rect(cutout, scale, viewport_rect.position))

	return {
		"physical_display_size": window_size,
		"physical_safe_area": physical_safe_area,
		"physical_cutouts": DisplayServer.get_display_cutouts(),
		"project_viewport_rect": viewport_rect,
		"project_safe_area": project_safe_area,
		"project_cutouts": project_cutouts,
		"scale": scale,
		"top_inset": maxf(project_safe_area.position.y - viewport_rect.position.y, 0.0),
		"bottom_inset": maxf(viewport_rect.end.y - project_safe_area.end.y, 0.0),
		"left_inset": maxf(project_safe_area.position.x - viewport_rect.position.x, 0.0),
		"right_inset": maxf(viewport_rect.end.x - project_safe_area.end.x, 0.0),
	}


static func apply_top_margin(
	margin_container: MarginContainer,
	base_top_margin: int,
	base_offset_bottom: float
) -> Dictionary:
	var info := get_safe_area_info(margin_container.get_viewport())
	var top_inset := float(info["top_inset"])
	margin_container.add_theme_constant_override("margin_top", _round_margin(float(base_top_margin) + top_inset))
	margin_container.offset_bottom = base_offset_bottom + top_inset
	return info


static func apply_full_rect_safe_area(
	control: Control,
	extra_top_margin := 0.0,
	extra_bottom_margin := 0.0
) -> Dictionary:
	var info := get_safe_area_info(control.get_viewport())
	control.offset_left = float(info["left_inset"])
	control.offset_top = float(info["top_inset"]) + extra_top_margin
	control.offset_right = -float(info["right_inset"])
	control.offset_bottom = -(float(info["bottom_inset"]) + extra_bottom_margin)
	return info


static func watch_viewport(control: Control, callback: Callable) -> void:
	var viewport := control.get_viewport()
	if viewport == null:
		return
	if not viewport.size_changed.is_connected(callback):
		viewport.size_changed.connect(callback)


static func _physical_rect_to_project_rect(rect: Rect2i, scale: Vector2, viewport_offset: Vector2) -> Rect2:
	var position := Vector2(float(rect.position.x), float(rect.position.y)) * scale + viewport_offset
	var size := Vector2(float(rect.size.x), float(rect.size.y)) * scale
	return Rect2(position, size)


static func _round_margin(value: float) -> int:
	return int(round(maxf(value, 0.0)))
