extends Node
class_name AudioManager

const MENU_BGM := preload("res://assets/bgm/menu_bgm.ogg")
const GAMEPLAY_BGM := preload("res://assets/bgm/in_game_bgm.ogg")
const PLAYER_FIRE_SFX := preload("res://assets/sfx/player_fire_sfx.wav")
const ENEMY_FIRE_SFX := preload("res://assets/sfx/enemy_fire_sfx.wav")
const ENEMY_DESTROYED_SFX := preload("res://assets/sfx/enemy_and_carrier_destroy_sfx.wav")
const PLAYER_DAMAGE_SFX := preload("res://assets/sfx/player_hurt_sfx.wav")
const SHIELD_ABSORB_SFX := preload("res://assets/sfx/shield_absorb_sfx.wav")
const GAME_OVER_SFX := preload("res://assets/sfx/game_over_sfx.wav")
const PICKUP_SFX := preload("res://assets/sfx/collect_items_sfx.wav")
const SHIELD_PICKUP_SFX := preload("res://assets/sfx/collect_shield_sfx.wav")
const WEAPON_UPGRADE_SFX := preload("res://assets/sfx/weapon_upgrade_sfx.wav")

const BGM_VOLUME_DB := -12.0
const SFX_VOLUME_DB := -6.0
const PLAYER_FIRE_VOLUME_DB := -12.0
const ENEMY_FIRE_VOLUME_DB := -10.0
const UI_VOLUME_DB := -9.0
const SFX_POOL_SIZE := 8

var _bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx_player_index := 0
var _active_bgm: AudioStream
var _bgm_was_paused := false
var _music_enabled := true
var _sound_enabled := true


func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	_bgm_player.volume_db = BGM_VOLUME_DB
	add_child(_bgm_player)

	for index in range(SFX_POOL_SIZE):
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer%d" % index
		sfx_player.volume_db = SFX_VOLUME_DB
		add_child(sfx_player)
		_sfx_players.append(sfx_player)

	_enable_loop(MENU_BGM)
	_enable_loop(GAMEPLAY_BGM)


func play_menu_bgm() -> void:
	_play_bgm(MENU_BGM)


func play_gameplay_bgm() -> void:
	_play_bgm(GAMEPLAY_BGM)


func pause_gameplay_bgm() -> void:
	if _active_bgm != GAMEPLAY_BGM or not _bgm_player.playing:
		return

	_bgm_player.stream_paused = true
	_bgm_was_paused = true


func resume_gameplay_bgm() -> void:
	if _active_bgm != GAMEPLAY_BGM:
		return

	if _bgm_was_paused:
		_bgm_player.stream_paused = false
		_bgm_was_paused = false
	elif not _bgm_player.playing:
		_bgm_player.play()


func stop_bgm() -> void:
	_bgm_player.stop()
	_bgm_player.stream = null
	_active_bgm = null
	_bgm_was_paused = false


func apply_settings(settings: Dictionary) -> void:
	_music_enabled = bool(settings.get("music_enabled", true))
	_sound_enabled = bool(settings.get("sound_enabled", true))
	if not _music_enabled:
		stop_bgm()
	if not _sound_enabled:
		_stop_sfx()


func play_player_fire_sfx() -> void:
	_play_sfx(PLAYER_FIRE_SFX, PLAYER_FIRE_VOLUME_DB)


func play_enemy_fire_sfx() -> void:
	_play_sfx(ENEMY_FIRE_SFX, ENEMY_FIRE_VOLUME_DB)


func play_enemy_destroyed_sfx() -> void:
	_play_sfx(ENEMY_DESTROYED_SFX)


func play_player_damage_sfx() -> void:
	_play_sfx(PLAYER_DAMAGE_SFX)


func play_shield_absorb_sfx() -> void:
	_play_sfx(SHIELD_ABSORB_SFX)


func play_game_over_sfx() -> void:
	_play_sfx(GAME_OVER_SFX)


func play_button_sfx() -> void:
	_play_sfx(PICKUP_SFX, UI_VOLUME_DB)


func play_pause_sfx() -> void:
	_play_sfx(PICKUP_SFX, UI_VOLUME_DB)


func play_resume_sfx() -> void:
	_play_sfx(PICKUP_SFX, UI_VOLUME_DB)


func play_weapon_pickup_sfx() -> void:
	_play_sfx(WEAPON_UPGRADE_SFX)


func play_booster_pickup_sfx() -> void:
	_play_sfx(SHIELD_PICKUP_SFX)


func _play_bgm(stream: AudioStream) -> void:
	if not _music_enabled:
		stop_bgm()
		return

	if _active_bgm == stream and _bgm_player.playing:
		_bgm_player.stream_paused = false
		_bgm_was_paused = false
		return

	_bgm_player.stop()
	_bgm_player.stream = stream
	_bgm_player.volume_db = BGM_VOLUME_DB
	_active_bgm = stream
	_bgm_was_paused = false
	_bgm_player.play()


func _play_sfx(stream: AudioStream, volume_db: float = SFX_VOLUME_DB) -> void:
	if not _sound_enabled:
		return

	var player := _get_available_sfx_player()
	player.stop()
	player.stream = stream
	player.volume_db = volume_db
	player.play()


func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player

	var player := _sfx_players[_next_sfx_player_index]
	_next_sfx_player_index = (_next_sfx_player_index + 1) % _sfx_players.size()
	return player


func _stop_sfx() -> void:
	for player in _sfx_players:
		player.stop()
		player.stream = null


func _enable_loop(stream: AudioStream) -> void:
	if stream is AudioStreamOggVorbis:
		stream.loop = true
