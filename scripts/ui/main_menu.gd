extends Control

signal start_requested

@onready var start_button: Button = %StartButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)


func _on_start_button_pressed() -> void:
	start_requested.emit()
