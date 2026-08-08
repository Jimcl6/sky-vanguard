extends Control

signal pause_requested
signal resume_requested
signal game_over_requested

@onready var pause_button: Button = %PauseButton
@onready var trigger_game_over_button: Button = %TriggerGameOverButton
@onready var pause_menu: Control = %PauseMenu


func _ready() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)
	trigger_game_over_button.pressed.connect(_on_trigger_game_over_button_pressed)
	pause_menu.resume_requested.connect(_on_resume_requested)


func set_pause_visible(should_show: bool) -> void:
	pause_menu.visible = should_show
	pause_button.disabled = should_show
	trigger_game_over_button.disabled = should_show


func set_flow_locked(is_locked: bool) -> void:
	pause_button.disabled = is_locked
	trigger_game_over_button.disabled = is_locked


func _on_pause_button_pressed() -> void:
	pause_requested.emit()


func _on_trigger_game_over_button_pressed() -> void:
	game_over_requested.emit()


func _on_resume_requested() -> void:
	resume_requested.emit()
