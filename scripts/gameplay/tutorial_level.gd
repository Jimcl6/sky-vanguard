extends Control

signal main_menu_requested
signal start_run_requested

const SAFE_AREA := preload("res://scripts/ui/safe_area_layout.gd")
const PAUSE_MENU := preload("res://scenes/ui/PauseMenu.tscn")
const LESSONS := [
	"DRAG TO MOVE",
	"DRAG LEFT",
	"DRAG RIGHT",
	"DRAG UP",
	"DRAG DOWN",
	"TEST THE SCREEN EDGE",
	"TAP PAUSE",
	"TUTORIAL COMPLETE",
]

@onready var player: Player = $World/Player
@onready var background: Parallax2D = $Background
@onready var guide: Node2D = $World/Guide

var step := 0
var paused := false
var target := Vector2.ZERO
var _audio_manager: Node
var _safe: Control
var _header: VBoxContainer
var _instruction: Label
var _progress: Label
var _hint: Label
var _pause_button: Button
var _pause_menu: Control
var _completion: VBoxContainer
var _pulse := 0.0
var _paused_for_lesson := false


func _ready() -> void:
	_build_ui()
	SAFE_AREA.watch_viewport(self, _refresh_layout)
	_refresh_layout()
	player.reset_for_run(Vector2(size.x * 0.5, size.y * 0.78))
	player.set_fire_enabled(false)
	player.set_damage_enabled(false)
	player.set_pickup_collection_enabled(false)
	player.set_movement_enabled(true)
	player.drag_started.connect(_on_drag_started)
	guide.draw.connect(_draw_guide)
	background.set_scrolling_enabled(true)
	_update_lesson()


func set_audio_manager(manager: Node) -> void:
	_audio_manager = manager


func _process(delta: float) -> void:
	if paused:
		return
	_pulse += delta
	var arrival_radius := 44.0
	if step >= 1 and step <= 5 and player.global_position.distance_to(target) <= arrival_radius:
		step += 1
		_update_lesson()
	guide.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		set_paused(not paused)
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if is_node_ready():
			set_paused(true, false)
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST and is_node_ready():
		set_paused(not paused)


func set_paused(value: bool, user_requested := true) -> void:
	if step == 7 or paused == value:
		return
	paused = value
	player.set_movement_enabled(not paused)
	background.set_scrolling_enabled(not paused)
	_pause_menu.visible = paused
	_safe.visible = not paused
	guide.visible = not paused
	if paused:
		_paused_for_lesson = step == 6 and user_requested
		if _audio_manager != null:
			_audio_manager.play_pause_sfx()
			_audio_manager.pause_gameplay_bgm()
	else:
		if _audio_manager != null:
			_audio_manager.play_resume_sfx()
			_audio_manager.resume_gameplay_bgm()
		if _paused_for_lesson:
			step = 7
			_update_lesson()
		_paused_for_lesson = false


func _on_drag_started() -> void:
	if step == 0 and not paused:
		step = 1
		_update_lesson()


func _update_lesson() -> void:
	_progress.text = "CONTROL FLIGHT   %d / 7" % mini(step + 1, 7)
	_instruction.text = LESSONS[step]
	_hint.text = "Lift anytime. Touch near your ship to re-grab."
	if step == 0:
		_hint.text = "Start inside the white circle."
	elif step == 5:
		_hint.text = "Drag to the left edge. Your ship stays on screen."
	elif step == 6:
		_hint.text = "Resume to finish training."
	elif step == 7:
		_progress.text = "CONTROL FLIGHT   COMPLETE"
		_hint.text = "In a run, your ship auto-fires. Focus on flying."
		player.set_movement_enabled(false)
		_pause_button.hide()
		_completion.show()
	_refresh_target()
	guide.queue_redraw()


func _refresh_target() -> void:
	match step:
		1: target = size * Vector2(0.22, 0.78)
		2: target = size * Vector2(0.78, 0.78)
		3: target = size * Vector2(0.78, 0.42)
		4: target = size * Vector2(0.78, 0.78)
		5: target = Vector2(player.bounds_margin.x, size.y * 0.65)


func _draw_guide() -> void:
	if step == 0:
		guide.draw_arc(player.position, player.touch_radius, 0, TAU, 64, Color(1, 1, 1, 0.8), 3.0, true)
	elif step >= 1 and step <= 5:
		var radius := 42.0 + sin(_pulse * 3.0) * 3.0
		guide.draw_circle(target, radius, Color(0.04, 0.08, 0.10, 0.65))
		guide.draw_arc(target, radius, 0, TAU, 48, Color(1, 0.85, 0.3), 4.0, true)
		guide.draw_line(target - Vector2(12, 0), target + Vector2(12, 0), Color.WHITE, 2)
		guide.draw_line(target - Vector2(0, 12), target + Vector2(0, 12), Color.WHITE, 2)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_safe = Control.new()
	_safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_safe)
	_safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_header = VBoxContainer.new()
	_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header.add_theme_constant_override("separation", 12)
	_safe.add_child(_header)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header.add_child(row)
	_progress = _label("", 24)
	_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_progress)
	_pause_button = _button("PAUSE", func() -> void: set_paused(true))
	row.add_child(_pause_button)
	_instruction = _label("", 34)
	_header.add_child(_instruction)
	_hint = _label("", 24)
	_header.add_child(_hint)
	_completion = VBoxContainer.new()
	_completion.add_theme_constant_override("separation", 18)
	_safe.add_child(_completion)
	_completion.add_child(_button("PLAY RUN", func() -> void: start_run_requested.emit()))
	_completion.add_child(_button("MAIN MENU", func() -> void: main_menu_requested.emit()))
	_completion.hide()
	_pause_menu = PAUSE_MENU.instantiate()
	layer.add_child(_pause_menu)
	_pause_menu.hide()
	_pause_menu.resume_requested.connect(func() -> void: set_paused(false))
	_pause_menu.main_menu_requested.connect(func() -> void: main_menu_requested.emit())


func _label(value: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.theme = theme
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	label.add_theme_constant_override("outline_size", 8)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(value: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = value
	button.theme = theme
	button.custom_minimum_size = Vector2(120, 72)
	button.pressed.connect(action)
	return button


func _refresh_layout() -> void:
	SAFE_AREA.apply_full_rect_safe_area(_safe, 24, 24)
	_header.position = Vector2(28, 0)
	_header.size.x = _safe.size.x - 56
	_completion.position = Vector2(80, _safe.size.y * 0.44)
	_completion.size.x = _safe.size.x - 160
	var texture_size: Vector2 = $Background/Ocean.texture.get_size()
	for sprite: Sprite2D in [$Background/Ocean, $Background/OceanMirrored]:
		sprite.scale = size / texture_size
	$Background/Ocean.position = size * 0.5
	$Background/OceanMirrored.position = Vector2(size.x * 0.5, size.y * 1.5)
	background.repeat_size = Vector2(0, size.y * 2)
	_refresh_target()
