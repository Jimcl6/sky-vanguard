extends Node
class_name ScoreSystem

signal score_changed(new_score: int)

var current_score := 0
var score_locked := false


func reset_score() -> void:
	current_score = 0
	score_locked = false
	score_changed.emit(current_score)


func add_score(amount: int) -> void:
	if score_locked or amount <= 0:
		return

	current_score += amount
	score_changed.emit(current_score)


func lock_score() -> void:
	score_locked = true
