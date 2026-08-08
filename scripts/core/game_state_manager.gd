extends Node
class_name GameStateManager

signal state_changed(previous_state: int, new_state: int)

enum State {
	BOOT,
	MAIN_MENU,
	STARTING_RUN,
	PLAYING,
	PAUSED,
	GAME_OVER,
	RESTARTING,
	RETURNING_TO_MENU,
}

var current_state: int = State.BOOT


func transition_to(new_state: int) -> void:
	if current_state == new_state:
		return

	var previous_state := current_state
	current_state = new_state
	state_changed.emit(previous_state, current_state)


func is_gameplay_allowed() -> bool:
	return current_state == State.PLAYING


func get_state_name(state: int = current_state) -> String:
	match state:
		State.BOOT:
			return "BOOT"
		State.MAIN_MENU:
			return "MAIN_MENU"
		State.STARTING_RUN:
			return "STARTING_RUN"
		State.PLAYING:
			return "PLAYING"
		State.PAUSED:
			return "PAUSED"
		State.GAME_OVER:
			return "GAME_OVER"
		State.RESTARTING:
			return "RESTARTING"
		State.RETURNING_TO_MENU:
			return "RETURNING_TO_MENU"
		_:
			return "UNKNOWN"
