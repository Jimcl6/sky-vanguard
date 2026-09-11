extends SceneTree

const THEME_PATH := "res://resources/ui/sky_vanguard_theme.tres"
const ASSET_PATHS := [
	"res://assets/fonts/orbitron/Orbitron.ttf",
	"res://assets/fonts/rajdhani/Rajdhani-Medium.ttf",
	"res://assets/fonts/rajdhani/Rajdhani-SemiBold.ttf",
	"res://assets/icons/vanguard_crest.png",
	"res://assets/icons/vanguard_crest_adaptive.png",
	"res://assets/icons/launcher_background.svg",
	"res://assets/ui/main_menu_title_pixel.png",
]
const SCENE_PATHS := {
	"MainMenu": "res://scenes/ui/MainMenu.tscn",
	"HUD": "res://scenes/ui/HUD.tscn",
	"PauseMenu": "res://scenes/ui/PauseMenu.tscn",
	"GameOverScreen": "res://scenes/ui/GameOverScreen.tscn",
	"TutorialLevel": "res://scenes/gameplay/TutorialLevel.tscn",
}
const REQUIRED_NODES := {
	"MainMenu": [
		"CenterContainer/Panel/MenuContent/TitleArt",
		"%StartButton",
		"%TutorialButton",
		"%SettingsButton",
		"%BestScoreLabel",
		"%SettingsPanel",
		"%BackButton",
		"%MenuParallax",
	],
	"HUD": ["%ScoreLabel", "%HPLabel", "%WeaponLabel", "%ShieldLabel", "%PauseButton"],
	"PauseMenu": ["%ResumeButton", "%MainMenuButton"],
	"GameOverScreen": [
		"%FinalScoreLabel",
		"%BestScoreLabel",
		"%NewBestLabel",
		"%ReviveButton",
		"%ReviveStatusLabel",
		"%RestartButton",
		"%MainMenuButton",
	],
	"TutorialLevel": [
		"TutorialUI/SafeArea",
		"TutorialUI/SafeArea/InstructionPanel",
		"TutorialUI/SafeArea/InstructionPanel/InstructionContent/ProgressRow/ProgressLabel",
		"TutorialUI/SafeArea/InstructionPanel/InstructionContent/ProgressRow/PauseButton",
		"TutorialUI/SafeArea/InstructionPanel/InstructionContent/InstructionLabel",
		"TutorialUI/SafeArea/InstructionPanel/InstructionContent/HintLabel",
		"TutorialUI/SafeArea/CompletionPanel/CompletionActions/PlayRunButton",
		"TutorialUI/SafeArea/CompletionPanel/CompletionActions/MainMenuButton",
		"TutorialUI/PauseMenu",
	],
}
const REQUIRED_VARIATIONS := [
	"VanguardBody",
	"VanguardButton",
	"VanguardDangerButton",
	"VanguardDangerHeading",
	"VanguardDangerPanel",
	"VanguardGold",
	"VanguardHeading",
	"VanguardHudPanel",
	"VanguardMuted",
	"VanguardPanel",
]

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var started_at_ms := Time.get_ticks_msec()
	var theme_resource := _validate_resources()
	if theme_resource == null:
		_finish(started_at_ms)
		return

	for viewport_size in [Vector2i(720, 1280), Vector2i(720, 1600)]:
		root.size = viewport_size
		for scene_name: String in SCENE_PATHS:
			await _validate_scene(scene_name, viewport_size, theme_resource)

	_finish(started_at_ms)


func _validate_resources() -> Theme:
	_check(ResourceLoader.exists(THEME_PATH), "Theme resource exists")
	var theme_resource := load(THEME_PATH) as Theme
	_check(theme_resource != null, "Theme resource loads")
	if theme_resource == null:
		return null

	for asset_path: String in ASSET_PATHS:
		_check(ResourceLoader.exists(asset_path), "Asset exists: %s" % asset_path)
		var asset := load(asset_path)
		_check(asset != null, "Asset loads: %s" % asset_path)
		if asset is Texture2D:
			_check(asset.get_width() > 0 and asset.get_height() > 0, "Image has dimensions: %s" % asset_path)

	for variation: String in REQUIRED_VARIATIONS:
		_check(not theme_resource.get_type_variation_base(variation).is_empty(), "Theme variation exists: %s" % variation)

	_check(theme_resource.get_font("font", "Button") != null, "Button font resolves")
	_check(theme_resource.get_font("font", "Label") != null, "Label font resolves")
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		_check(theme_resource.get_stylebox(state, "VanguardButton") != null, "Button state resolves: %s" % state)
	_check(theme_resource.get_stylebox("normal", "VanguardDangerButton") != null, "Danger button normal style resolves")
	_check(theme_resource.get_stylebox("disabled", "VanguardDangerButton") != null, "Danger button disabled style resolves")
	return theme_resource


func _validate_scene(scene_name: String, viewport_size: Vector2i, theme_resource: Theme) -> void:
	var scene_path: String = SCENE_PATHS[scene_name]
	_check(ResourceLoader.exists(scene_path), "%s scene exists" % scene_name)
	var packed_scene := load(scene_path) as PackedScene
	_check(packed_scene != null, "%s scene loads" % scene_name)
	if packed_scene == null:
		return

	var ui := packed_scene.instantiate() as Control
	_check(ui != null, "%s scene instantiates" % scene_name)
	if ui == null:
		return

	root.add_child(ui)
	await process_frame
	_check(ui.theme == theme_resource, "%s uses the shared theme" % scene_name)
	for node_path: String in REQUIRED_NODES[scene_name]:
		_check(ui.get_node_or_null(node_path) != null, "%s key node exists: %s" % [scene_name, node_path])

	_apply_test_state(ui, scene_name)
	await process_frame
	_check_control_tree(ui, scene_name, viewport_size)
	_check_scene_contract(ui, scene_name)

	ui.queue_free()
	await process_frame


func _apply_test_state(ui: Control, scene_name: String) -> void:
	match scene_name:
		"MainMenu":
			ui.call("set_best_score", 999999999)
		"HUD":
			ui.call("update_score", 999999999)
			ui.call("update_hp", 3, 3)
			ui.call("update_weapon", "spread_shot", "Spread Shot")
			ui.call("update_shield", true, 3, 10.0)
		"GameOverScreen":
			ui.call("set_scores", 999999999, 999999999, true)
			ui.call("set_revive_state", false, false, "AD UNAVAILABLE")
		"TutorialLevel":
			ui.set("step", 7)
			ui.call("_update_lesson")


func _check_control_tree(node: Node, scene_name: String, viewport_size: Vector2i) -> void:
	if node is Control and node.is_visible_in_tree():
		var control := node as Control
		if control is Button:
			_check(control.custom_minimum_size.y >= 68.0, "%s touch target is at least 68 px: %s" % [scene_name, control.name])
		var should_check_single_line := control is Button
		if control is Label:
			should_check_single_line = (control as Label).autowrap_mode == TextServer.AUTOWRAP_OFF
		if should_check_single_line:
			var font := control.get_theme_font("font")
			var font_size := control.get_theme_font_size("font_size")
			var text := str(control.get("text"))
			var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			_check(text_width <= control.size.x + 1.0, "%s text fits: %s" % [scene_name, control.name])
		var rect := control.get_global_rect()
		_check(rect.position.x >= -1.0 and rect.position.y >= -1.0, "%s control starts on-screen: %s" % [scene_name, control.name])
		_check(rect.end.x <= float(viewport_size.x) + 1.0 and rect.end.y <= float(viewport_size.y) + 1.0, "%s control ends on-screen: %s" % [scene_name, control.name])

	for child: Node in node.get_children():
		_check_control_tree(child, scene_name, viewport_size)


func _check_scene_contract(ui: Control, scene_name: String) -> void:
	match scene_name:
		"MainMenu":
			var center := ui.get_node("CenterContainer") as Control
			_check(center.offset_bottom <= -96.0, "Main Menu reserves bottom banner clearance")
			_check((ui.get_node("CenterContainer/Panel/MenuContent/TitleArt") as TextureRect).texture != null, "Main Menu title image resolves")
			_check(_button_is_connected(ui, "%StartButton"), "START button signal is connected")
			_check(_button_is_connected(ui, "%TutorialButton"), "TUTORIAL button signal is connected")
			_check(_button_is_connected(ui, "%SettingsButton"), "SETTINGS button signal is connected")
		"HUD":
			var margin := ui.get_node("MarginContainer") as MarginContainer
			_check(margin.get_theme_constant("margin_top") >= 18, "HUD keeps its safe top margin")
			_check(_button_is_connected(ui, "%PauseButton"), "HUD pause button signal is connected")
		"PauseMenu":
			_check(_button_is_connected(ui, "%ResumeButton"), "RESUME button signal is connected")
			_check(_button_is_connected(ui, "%MainMenuButton"), "Pause Main Menu button signal is connected")
		"GameOverScreen":
			var revive_button := ui.get_node("%ReviveButton") as Button
			_check(revive_button.disabled, "Revive disabled state is preserved")
			_check(_button_is_connected(ui, "%ReviveButton"), "Rewarded revive button signal is connected")
			_check(_button_is_connected(ui, "%RestartButton"), "RESTART button signal is connected")
			_check(_button_is_connected(ui, "%MainMenuButton"), "Game Over Main Menu button signal is connected")
		"TutorialLevel":
			var safe_area := ui.get_node("TutorialUI/SafeArea") as Control
			var instruction_panel := ui.get_node("TutorialUI/SafeArea/InstructionPanel") as PanelContainer
			var progress_label := ui.get_node("TutorialUI/SafeArea/InstructionPanel/InstructionContent/ProgressRow/ProgressLabel") as Label
			var instruction_label := ui.get_node("TutorialUI/SafeArea/InstructionPanel/InstructionContent/InstructionLabel") as Label
			var hint_label := ui.get_node("TutorialUI/SafeArea/InstructionPanel/InstructionContent/HintLabel") as Label
			var completion_panel := ui.get_node("TutorialUI/SafeArea/CompletionPanel") as PanelContainer
			_check(safe_area.offset_top >= 24.0 and safe_area.offset_bottom <= -24.0, "Tutorial keeps safe-area padding")
			_check(safe_area.theme == ui.theme, "Tutorial UI inherits the shared theme across CanvasLayer")
			_check(instruction_panel.theme_type_variation == &"VanguardHudPanel", "Tutorial instruction panel uses HUD styling")
			_check(instruction_panel.get_theme_stylebox("panel") == ui.theme.get_stylebox("panel", "VanguardHudPanel"), "Tutorial instruction panel resolves shared styling")
			_check(progress_label.theme_type_variation == &"VanguardGold", "Tutorial progress uses gold styling")
			_check(progress_label.get_theme_font("font") == ui.theme.get_font("font", "VanguardGold"), "Tutorial progress resolves shared font")
			_check(instruction_label.theme_type_variation == &"VanguardHeading", "Tutorial instruction uses heading styling")
			_check(instruction_label.get_theme_font("font") == ui.theme.get_font("font", "VanguardHeading"), "Tutorial instruction resolves shared heading font")
			_check(hint_label.theme_type_variation == &"VanguardMuted", "Tutorial hint uses muted styling")
			_check(completion_panel.theme_type_variation == &"VanguardPanel", "Tutorial completion uses panel styling")
			_check(_button_is_connected(ui, "TutorialUI/SafeArea/CompletionPanel/CompletionActions/PlayRunButton"), "PLAY RUN button signal is connected")
			_check(_button_is_connected(ui, "TutorialUI/SafeArea/CompletionPanel/CompletionActions/MainMenuButton"), "Tutorial Main Menu button signal is connected")


func _button_is_connected(ui: Control, node_path: String) -> bool:
	var button := ui.get_node_or_null(node_path) as Button
	return button != null and not button.pressed.get_connections().is_empty()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _finish(started_at_ms: int) -> void:
	var elapsed_ms := Time.get_ticks_msec() - started_at_ms
	print("UI_THEME_VALIDATION failures=%d elapsed_ms=%d" % [failures, elapsed_ms])
	quit(failures)
