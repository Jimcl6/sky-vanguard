extends Area2D
class_name WeaponPickup

const WEAPON_BASIC_BLASTER := "basic_blaster"
const WEAPON_SPREAD_SHOT := "spread_shot"
const BASIC_BLASTER_TEXTURE := preload("res://assets/sprites/pickups/weapon_pickup_basic_blaster.png")
const SPREAD_SHOT_TEXTURE := preload("res://assets/sprites/pickups/weapon_pickup_spread_shot.png")
const VALID_WEAPON_IDS := [
	WEAPON_BASIC_BLASTER,
	WEAPON_SPREAD_SHOT,
]

@export_enum("basic_blaster", "spread_shot") var weapon_id := WEAPON_SPREAD_SHOT
@export var label_prefix := "Weapon"

@onready var visual: Sprite2D = $Visual
@onready var label: Label = $Label

var _was_collected := false


func _ready() -> void:
	_apply_visual()


func collect_by_player(player: Node) -> bool:
	if _was_collected or not is_valid_weapon_id(weapon_id):
		return false

	if not player.has_method("collect_weapon_pickup"):
		return false

	var did_collect: Variant = player.call("collect_weapon_pickup", weapon_id)
	if did_collect != true:
		return false

	_was_collected = true
	_play_collected_feedback(player)
	queue_free()
	return true


static func is_valid_weapon_id(candidate_weapon_id: String) -> bool:
	return VALID_WEAPON_IDS.has(candidate_weapon_id)


static func get_weapon_display_name(candidate_weapon_id: String) -> String:
	match candidate_weapon_id:
		WEAPON_BASIC_BLASTER:
			return "Basic Blaster"
		WEAPON_SPREAD_SHOT:
			return "Spread Shot"
		_:
			return "Unknown Weapon"


func _apply_visual() -> void:
	label.text = "%s: %s" % [label_prefix, get_weapon_display_name(weapon_id)]

	match weapon_id:
		WEAPON_BASIC_BLASTER:
			visual.texture = BASIC_BLASTER_TEXTURE
		WEAPON_SPREAD_SHOT:
			visual.texture = SPREAD_SHOT_TEXTURE
		_:
			visual.texture = null


func _play_collected_feedback(player: Node) -> void:
	if not player.has_method("get_feedback_manager"):
		return

	var feedback_manager: Variant = player.call("get_feedback_manager")
	if feedback_manager != null and feedback_manager.has_method("play_weapon_pickup_collected"):
		feedback_manager.call("play_weapon_pickup_collected", global_position, weapon_id)
