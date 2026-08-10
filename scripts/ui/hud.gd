extends Control
class_name HUD

@onready var score_label: Label = %ScoreLabel
@onready var hp_label: Label = %HPLabel


func _ready() -> void:
	update_score(0)
	update_hp(0, 0)


func update_score(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score


func update_hp(current_hp: int, max_hp: int) -> void:
	if max_hp <= 0:
		hp_label.text = "HP: --"
		return

	hp_label.text = "HP: %d" % current_hp
