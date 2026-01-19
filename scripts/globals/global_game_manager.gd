extends Node


const LEVEL_ONE = preload("uid://c0rjmcisgel26")
const LEVEL_TWO = preload("uid://defnhonhw5r5g")
const LEVEL_THREE = preload("uid://bmo5w2c86foo1")
const LEVEL_FOUR = preload("uid://ch21n7wdbhsr5")
const TEST_ONE = preload("uid://ieqnodo2xffy")
const ICE_TWO = preload("uid://123fvdy454jp")
const MAX_SANDBAGS = 3
const AUTOMATIC_RESTART = false

var levels: Array[PackedScene] = []
var _current_level: PackedScene
var turn_manager: TurnManager
var has_key: bool = false:
	set(v):
		if has_key != v:
			has_key = v
			Events.has_key_changed.emit(v)
var has_sand: bool:
	get:
		return sandbags > 0
var sandbags: int = 0:
	set(v):
		v = clampi(v, 0, MAX_SANDBAGS)
		if sandbags != v:
			sandbags = v
			Events.sand_picked_up.emit(v)
var bridge: bool = false


func _ready() -> void:
	Events.level_completed.connect(_on_level_completed)
	Events.key_picked_up.connect(func(): has_key = true)
	Events.key_used.connect(func(): has_key = false)

	# Auto restart or show fail message and hint?
	if not AUTOMATIC_RESTART:
		Events.level_failed.connect(restart_level)


## Start a new game
func new_game() -> void:
	levels = [
		#TEST_ONE,
		ICE_TWO,
		LEVEL_ONE,
		LEVEL_FOUR,
		#LEVEL_TWO,
		LEVEL_THREE,
	]
	_on_level_completed()


## Attempt to open door, checks if players has picked up key
func open_door() -> bool:
	if has_key:  # TODO play an animation, open the door, then disable the player
		Events.level_completed.emit()
	else:
		print("You need key!")
	return has_key


## Attempt to pick up sand, returns false if no room
func pickup_sand() -> bool:
	if sandbags < MAX_SANDBAGS:
		sandbags += 1
		return true
	else:
		return false


## Attempt to use sand, returns false if player has no sand to use
func use_sand() -> bool:
	if has_sand:
		sandbags -= 1
		Events.sand_used.emit()
		return true
	else:
		return false


## Attempt to pick up bridge, returns false if player already has bridge parts
func pickup_bridge() -> bool:
	if bridge:
		return false
	else:
		bridge = true
		Events.bridge_picked_up.emit()
		return true


## Attempt to use bridge, returns false if player does not have bridge parts
func use_bridge() -> bool:
	if not bridge:
		return false
	Events.bridge_used.emit()
	bridge = false
	return true


## Register yourself as an actor that wants to do something on each turn
func register(callback: Callable, done: Signal) -> bool:
	if not turn_manager:
		return false
	turn_manager.register(callback, done)
	return true


## Cleanup before you die by unregistering yourself from the turn order
func unregister(callback: Callable, done: Signal) -> bool:
	if not turn_manager:
		return false
	turn_manager.unregister(callback, done)
	return true


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_level_completed() -> void:
	if levels.size() > 0:
		_current_level = levels.pop_front()
		if _current_level == null:
			push_error("NO LEVEL??")
			return
		print(_current_level)
		get_tree().call_deferred("change_scene_to_packed", _current_level)
		if not get_tree().scene_changed.is_connected(_on_scene_changed):
			get_tree().scene_changed.connect(_on_scene_changed)
	else:
		Events.game_wun.emit()


## Force restart of the current level
func restart_level() -> void:
	get_tree().reload_current_scene()


func _on_scene_changed() -> void:
	_reset_player_inventory()
	turn_manager = get_tree().get_first_node_in_group("turn_manager")
	assert(turn_manager)
	Events.level_changed.emit()


# Since we start each level fresh, no should be maintained
func _reset_player_inventory() -> void:
	has_key = false
	bridge = false
	sandbags = 0
