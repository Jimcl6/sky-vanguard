extends Control

signal restart_requested
signal main_menu_requested

@onready var final_score_label: Label = %FinalScoreLabel
@onready var best_score_label: Label = %BestScoreLabel
@onready var new_best_label: Label = %NewBestLabel
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)


func set_final_score(final_score: int) -> void:
	set_scores(final_score, 0, false)


func set_scores(final_score: int, best_score: int, is_new_best: bool) -> void:
	final_score_label.text = "Final Score %d" % maxi(final_score, 0)
	best_score_label.text = "Best Score %d" % maxi(best_score, 0)
	new_best_label.visible = is_new_best


func _on_restart_button_pressed() -> void:
	restart_requested.emit()


func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()
