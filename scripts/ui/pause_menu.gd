extends Control

signal resume_requested

@onready var resume_button: Button = %ResumeButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_button_pressed)


func _on_resume_button_pressed() -> void:
	resume_requested.emit()
