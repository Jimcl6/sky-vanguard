extends Control
class_name HUD

signal pause_requested

const SAFE_AREA_LAYOUT := preload("res://scripts/ui/safe_area_layout.gd")
const BASE_TOP_MARGIN := 18
const BASE_TOP_OFFSET_BOTTOM := 128.0

@onready var margin_container: MarginContainer = $MarginContainer
@onready var score_label: Label = %ScoreLabel
@onready var hp_label: Label = %HPLabel
@onready var weapon_label: Label = %WeaponLabel
@onready var shield_label: Label = %ShieldLabel
@onready var pause_button: Button = %PauseButton


func _ready() -> void:
	SAFE_AREA_LAYOUT.watch_viewport(self, _refresh_safe_area)
	_refresh_safe_area()
	pause_button.pressed.connect(_on_pause_button_pressed)
	update_score(0)
	update_hp(0, 0)
	update_weapon("basic_blaster", "Basic Blaster")
	update_shield(false, 0, 0.0)


func set_pause_enabled(should_enable: bool) -> void:
	pause_button.disabled = not should_enable


func update_score(new_score: int) -> void:
	score_label.text = "Score %d" % new_score


func update_hp(current_hp: int, max_hp: int) -> void:
	if max_hp <= 0:
		hp_label.text = "HP --"
		return

	hp_label.text = "HP %d" % current_hp


func update_weapon(_weapon_id: String, display_name: String) -> void:
	weapon_label.text = "Weapon %s" % display_name


func update_shield(is_active: bool, hits_remaining: int, _duration_remaining: float) -> void:
	if not is_active:
		shield_label.text = "Shield Off"
		return

	shield_label.text = "Shield %d hits" % hits_remaining


func _on_pause_button_pressed() -> void:
	pause_requested.emit()


func _refresh_safe_area() -> void:
	SAFE_AREA_LAYOUT.apply_top_margin(margin_container, BASE_TOP_MARGIN, BASE_TOP_OFFSET_BOTTOM)
