extends Area2D
class_name BoosterPickup

const BOOSTER_TEMPORARY_SHIELD := "temporary_shield"
const VALID_BOOSTER_IDS := [
	BOOSTER_TEMPORARY_SHIELD,
]

@export_enum("temporary_shield") var booster_id := BOOSTER_TEMPORARY_SHIELD
@export var shield_duration := 5.0
@export var shield_hit_count := 2
@export var label_prefix := "Booster"

@onready var visual: Polygon2D = $Visual
@onready var label: Label = $Label

var _was_collected := false


func _ready() -> void:
	_apply_placeholder_visual()


func collect_by_player(player: Node) -> bool:
	if _was_collected or not is_valid_booster_id(booster_id):
		return false

	if not player.has_method("collect_booster_pickup"):
		return false

	var did_collect: Variant = player.call("collect_booster_pickup", booster_id, shield_duration, shield_hit_count)
	if did_collect != true:
		return false

	_was_collected = true
	queue_free()
	return true


static func is_valid_booster_id(candidate_booster_id: String) -> bool:
	return VALID_BOOSTER_IDS.has(candidate_booster_id)


static func get_booster_display_name(candidate_booster_id: String) -> String:
	match candidate_booster_id:
		BOOSTER_TEMPORARY_SHIELD:
			return "Temporary Shield"
		_:
			return "Unknown Booster"


func _apply_placeholder_visual() -> void:
	label.text = "%s: %s" % [label_prefix, get_booster_display_name(booster_id)]

	match booster_id:
		BOOSTER_TEMPORARY_SHIELD:
			visual.color = Color(0.466667, 0.933333, 1.0, 1.0)
		_:
			visual.color = Color(1.0, 1.0, 1.0, 1.0)
