extends Parallax2D

@export var scroll_speed := 90.0


func set_scrolling_enabled(should_enable: bool) -> void:
	autoscroll = Vector2.DOWN * scroll_speed if should_enable else Vector2.ZERO


func reset_scroll() -> void:
	scroll_offset = Vector2.ZERO
