extends Control

signal start_requested

@onready var start_button: Button = %StartButton
@onready var best_score_label: Label = %BestScoreLabel


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)


func set_best_score(best_score: int) -> void:
	best_score_label.text = "Best Score: %d" % maxi(best_score, 0)


func _on_start_button_pressed() -> void:
	start_requested.emit()
