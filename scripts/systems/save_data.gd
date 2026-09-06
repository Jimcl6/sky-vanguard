extends RefCounted

signal best_score_changed(best_score: int)

const SAVE_PATH := "user://save_data.json"
const DEFAULT_SETTINGS := {
	"sound_enabled": true,
	"music_enabled": true,
	"haptics_enabled": true,
	"screen_shake_enabled": true,
}

var best_score := 0
var settings := DEFAULT_SETTINGS.duplicate(true)


func load_data() -> void:
	reset_to_defaults()

	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Save data could not be opened. Defaults will be used.")
		return

	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK:
		push_warning("Save data is invalid JSON. Defaults will be used.")
		reset_to_defaults()
		return

	var parsed_data: Variant = json.data
	if not (parsed_data is Dictionary):
		push_warning("Save data root is not an object. Defaults will be used.")
		reset_to_defaults()
		return

	var loaded_data := parsed_data as Dictionary
	best_score = _sanitize_score(loaded_data.get("best_score", 0))
	settings = _sanitize_settings(loaded_data.get("settings", {}))


func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Save data could not be written.")
		return

	var payload := {
		"best_score": best_score,
		"settings": settings,
	}
	file.store_string(JSON.stringify(payload, "\t"))


func get_best_score() -> int:
	return best_score


func get_settings() -> Dictionary:
	return settings.duplicate(true)


func set_setting(setting_name: String, value: Variant) -> void:
	if not DEFAULT_SETTINGS.has(setting_name):
		return

	var default_value: Variant = DEFAULT_SETTINGS[setting_name]
	if typeof(value) != typeof(default_value):
		return

	settings[setting_name] = value
	save_data()


func submit_score(score: int) -> bool:
	var sanitized_score := maxi(score, 0)
	if sanitized_score <= best_score:
		return false

	best_score = sanitized_score
	save_data()
	best_score_changed.emit(best_score)
	return true


func reset_to_defaults() -> void:
	best_score = 0
	settings = DEFAULT_SETTINGS.duplicate(true)


func _sanitize_score(value: Variant) -> int:
	match typeof(value):
		TYPE_INT, TYPE_FLOAT:
			return maxi(int(value), 0)
		_:
			return 0


func _sanitize_settings(value: Variant) -> Dictionary:
	var sanitized_settings := DEFAULT_SETTINGS.duplicate(true)
	if not (value is Dictionary):
		return sanitized_settings

	var loaded_settings := value as Dictionary
	for setting_name in DEFAULT_SETTINGS.keys():
		var default_value: Variant = DEFAULT_SETTINGS[setting_name]
		var loaded_value: Variant = loaded_settings.get(setting_name, default_value)
		if typeof(loaded_value) == typeof(default_value):
			sanitized_settings[setting_name] = loaded_value

	return sanitized_settings
