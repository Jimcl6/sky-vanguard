extends Control

signal restart_requested
signal main_menu_requested

@onready var final_score_label: Label = %FinalScoreLabel
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)


func set_final_score(final_score: int) -> void:
	final_score_label.text = "Final Score %d" % final_score


func _on_restart_button_pressed() -> void:
	restart_requested.emit()


func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()
