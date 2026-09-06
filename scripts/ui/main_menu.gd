extends Control

signal start_requested
signal settings_button_pressed
signal settings_back_pressed
signal setting_changed(setting_name: String, value: bool)

@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var settings_panel: PanelContainer = %SettingsPanel
@onready var music_toggle_button: Button = %MusicToggleButton
@onready var sfx_toggle_button: Button = %SfxToggleButton
@onready var haptics_toggle_button: Button = %HapticsToggleButton
@onready var back_button: Button = %BackButton
@onready var best_score_label: Label = %BestScoreLabel
@onready var menu_parallax: Parallax2D = %MenuParallax

var _settings := {
	"music_enabled": true,
	"sound_enabled": true,
	"haptics_enabled": true,
}


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	music_toggle_button.pressed.connect(_on_music_toggle_button_pressed)
	sfx_toggle_button.pressed.connect(_on_sfx_toggle_button_pressed)
	haptics_toggle_button.pressed.connect(_on_haptics_toggle_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	menu_parallax.set_scrolling_enabled(true)
	_update_settings_labels()


func _exit_tree() -> void:
	if is_instance_valid(menu_parallax):
		menu_parallax.set_scrolling_enabled(false)


func set_best_score(best_score: int) -> void:
	best_score_label.text = "Best Score: %d" % maxi(best_score, 0)


func set_settings(settings: Dictionary) -> void:
	_settings["music_enabled"] = bool(settings.get("music_enabled", true))
	_settings["sound_enabled"] = bool(settings.get("sound_enabled", true))
	_settings["haptics_enabled"] = bool(settings.get("haptics_enabled", true))
	_update_settings_labels()


func _on_start_button_pressed() -> void:
	start_requested.emit()


func _on_settings_button_pressed() -> void:
	settings_button_pressed.emit()
	settings_panel.visible = true


func _on_music_toggle_button_pressed() -> void:
	_toggle_setting("music_enabled")


func _on_sfx_toggle_button_pressed() -> void:
	_toggle_setting("sound_enabled")


func _on_haptics_toggle_button_pressed() -> void:
	_toggle_setting("haptics_enabled")


func _on_back_button_pressed() -> void:
	settings_back_pressed.emit()
	settings_panel.visible = false


func _toggle_setting(setting_name: String) -> void:
	var new_value := not bool(_settings.get(setting_name, true))
	_settings[setting_name] = new_value
	_update_settings_labels()
	setting_changed.emit(setting_name, new_value)


func _update_settings_labels() -> void:
	if music_toggle_button == null:
		return

	music_toggle_button.text = "MUSIC: %s" % _format_toggle_value(bool(_settings["music_enabled"]))
	sfx_toggle_button.text = "SFX: %s" % _format_toggle_value(bool(_settings["sound_enabled"]))
	haptics_toggle_button.text = "HAPTICS: %s" % _format_toggle_value(bool(_settings["haptics_enabled"]))


func _format_toggle_value(is_enabled: bool) -> String:
	return "ON" if is_enabled else "OFF"
