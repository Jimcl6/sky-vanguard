extends Control

signal restart_requested
signal main_menu_requested
signal revive_requested

const SAFE_AREA_LAYOUT := preload("res://scripts/ui/safe_area_layout.gd")

@onready var center_container: CenterContainer = $CenterContainer
@onready var final_score_label: Label = %FinalScoreLabel
@onready var best_score_label: Label = %BestScoreLabel
@onready var new_best_label: Label = %NewBestLabel
@onready var revive_button: Button = %ReviveButton
@onready var revive_status_label: Label = %ReviveStatusLabel
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	SAFE_AREA_LAYOUT.watch_viewport(self, _refresh_safe_area)
	_refresh_safe_area()
	revive_button.pressed.connect(_on_revive_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)


func set_final_score(final_score: int) -> void:
	set_scores(final_score, 0, false)


func set_scores(final_score: int, best_score: int, is_new_best: bool) -> void:
	final_score_label.text = "Final Score %d" % maxi(final_score, 0)
	best_score_label.text = "Best Score %d" % maxi(best_score, 0)
	new_best_label.visible = is_new_best


func set_revive_state(can_show: bool, should_hide: bool, status_text: String) -> void:
	revive_button.visible = not should_hide
	revive_button.disabled = not can_show
	revive_status_label.text = status_text
	revive_status_label.visible = not should_hide and not status_text.is_empty()


func _on_revive_button_pressed() -> void:
	if not revive_button.disabled:
		revive_requested.emit()


func _on_restart_button_pressed() -> void:
	restart_requested.emit()


func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()


func _refresh_safe_area() -> void:
	SAFE_AREA_LAYOUT.apply_full_rect_safe_area(center_container)
