extends Control

signal resume_requested
signal main_menu_requested

@onready var resume_button: Button = %ResumeButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)


func _on_resume_button_pressed() -> void:
	resume_requested.emit()


func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()
