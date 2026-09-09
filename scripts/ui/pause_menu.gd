extends Control

signal resume_requested
signal main_menu_requested

const SAFE_AREA_LAYOUT := preload("res://scripts/ui/safe_area_layout.gd")

@onready var center_container: CenterContainer = $CenterContainer
@onready var resume_button: Button = %ResumeButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	SAFE_AREA_LAYOUT.watch_viewport(self, _refresh_safe_area)
	_refresh_safe_area()
	resume_button.pressed.connect(_on_resume_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)


func _on_resume_button_pressed() -> void:
	resume_requested.emit()


func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()


func _refresh_safe_area() -> void:
	SAFE_AREA_LAYOUT.apply_full_rect_safe_area(center_container)
