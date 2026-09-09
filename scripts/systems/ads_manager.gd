extends Node
class_name AdsManager

signal rewarded_ready_changed(is_ready: bool)
signal rewarded_session_finished(reward_earned: bool)

const ADMOB_SINGLETON_NAME := "AdmobPlugin"

@onready var _admob: Node = get_node_or_null("Admob")

var _ads_available := false
var _initialization_requested := false
var _initialized := false
var _banner_should_be_visible := false
var _banner_loading := false
var _banner_loaded := false
var _rewarded_preload_requested := false
var _rewarded_loading := false
var _rewarded_loaded := false
var _rewarded_showing := false
var _reward_earned_for_current_show := false


func _enter_tree() -> void:
	if OS.has_feature("android"):
		return

	var admob_node := get_node_or_null("Admob")
	if admob_node != null:
		remove_child(admob_node)
		admob_node.queue_free()


func _ready() -> void:
	_ads_available = _admob != null and OS.has_feature("android") and Engine.has_singleton(ADMOB_SINGLETON_NAME)
	if not _ads_available:
		return

	_connect_admob_signals()
	initialize_ads()


func initialize_ads() -> void:
	if not _ads_available or _initialization_requested or _initialized:
		return

	if bool(_admob.get("is_initialization_completed")):
		_on_initialization_completed(null)
		return

	_initialization_requested = true
	_admob.call("initialize")


func show_main_menu_banner() -> void:
	_banner_should_be_visible = true
	if not _initialized:
		return

	if _banner_loaded:
		_admob.call("show_banner_ad")
	elif not _banner_loading:
		_banner_loading = true
		_admob.call("load_banner_ad")


func hide_banner() -> void:
	_banner_should_be_visible = false
	if _banner_loaded:
		_admob.call("hide_banner_ad")


func preload_rewarded_revive_ad() -> void:
	_rewarded_preload_requested = true
	_load_rewarded_if_needed()


func is_rewarded_revive_ready() -> bool:
	if not _initialized or _rewarded_loading or _rewarded_showing or not _rewarded_loaded:
		return false

	return bool(_admob.call("is_rewarded_ad_loaded"))


func is_rewarded_loading() -> bool:
	return _rewarded_loading


func are_ads_available() -> bool:
	return _ads_available


func show_rewarded_revive_ad() -> bool:
	if not is_rewarded_revive_ready():
		return false

	_rewarded_showing = true
	_rewarded_loaded = false
	_reward_earned_for_current_show = false
	_rewarded_preload_requested = false
	rewarded_ready_changed.emit(false)
	_admob.call("show_rewarded_ad")
	return true


func _connect_admob_signals() -> void:
	_admob.connect("initialization_completed", _on_initialization_completed)
	_admob.connect("banner_ad_loaded", _on_banner_ad_loaded)
	_admob.connect("banner_ad_failed_to_load", _on_banner_ad_failed_to_load)
	_admob.connect("rewarded_ad_loaded", _on_rewarded_ad_loaded)
	_admob.connect("rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load)
	_admob.connect("rewarded_ad_failed_to_show_full_screen_content", _on_rewarded_ad_failed_to_show)
	_admob.connect("rewarded_ad_dismissed_full_screen_content", _on_rewarded_ad_dismissed)
	_admob.connect("rewarded_ad_user_earned_reward", _on_rewarded_ad_user_earned_reward)


func _on_initialization_completed(_status_data: Variant) -> void:
	_initialization_requested = true
	_initialized = true
	if _banner_should_be_visible:
		show_main_menu_banner()
	_load_rewarded_if_needed()


func _on_banner_ad_loaded(_ad_info: Variant, _response_info: Variant) -> void:
	_banner_loading = false
	_banner_loaded = true
	if _banner_should_be_visible:
		_admob.call("show_banner_ad")
	else:
		_admob.call("hide_banner_ad")


func _on_banner_ad_failed_to_load(_ad_info: Variant, error_data: Variant) -> void:
	_banner_loading = false
	_banner_loaded = false
	push_warning("AdMob banner failed to load: %s" % _get_error_message(error_data))


func _load_rewarded_if_needed() -> void:
	if not _initialized or not _rewarded_preload_requested:
		return
	if _rewarded_loading or _rewarded_showing or _rewarded_loaded:
		return

	_rewarded_loading = true
	rewarded_ready_changed.emit(false)
	_admob.call("load_rewarded_ad")


func _on_rewarded_ad_loaded(_ad_info: Variant, _response_info: Variant) -> void:
	_rewarded_loading = false
	_rewarded_loaded = true
	rewarded_ready_changed.emit(true)


func _on_rewarded_ad_failed_to_load(_ad_info: Variant, error_data: Variant) -> void:
	_rewarded_loading = false
	_rewarded_loaded = false
	_rewarded_preload_requested = false
	push_warning("AdMob rewarded ad failed to load: %s" % _get_error_message(error_data))
	rewarded_ready_changed.emit(false)


func _on_rewarded_ad_user_earned_reward(_ad_info: Variant, _reward_data: Variant) -> void:
	if _rewarded_showing:
		_reward_earned_for_current_show = true


func _on_rewarded_ad_dismissed(_ad_info: Variant) -> void:
	var did_earn_reward := _reward_earned_for_current_show
	_finish_rewarded_session(did_earn_reward)


func _on_rewarded_ad_failed_to_show(_ad_info: Variant, error_data: Variant) -> void:
	push_warning("AdMob rewarded ad failed to show: %s" % _get_error_message(error_data))
	if bool(_admob.call("is_rewarded_ad_loaded")):
		_admob.call("remove_rewarded_ad")
	_finish_rewarded_session(false)


func _finish_rewarded_session(did_earn_reward: bool) -> void:
	_rewarded_showing = false
	_rewarded_loading = false
	_rewarded_loaded = false
	_reward_earned_for_current_show = false
	_rewarded_preload_requested = true
	rewarded_ready_changed.emit(false)
	rewarded_session_finished.emit(did_earn_reward)
	_load_rewarded_if_needed()


func _get_error_message(error_data: Variant) -> String:
	if error_data is Object and error_data.has_method("get_message"):
		return str(error_data.call("get_message"))
	return "unknown error"
