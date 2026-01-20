class_name TurnManager
extends Node


const TURN_DURATION := 0.2

var _current_turn: int = 0
var _callbacks: Array[Callable] = []
var _actors_this_turn: int = 0
var _done_counter: int = 0


func _ready() -> void:
	add_to_group(&"turn_manager")
	Events.player_initiated_turn.connect(start_turn)


## Register yourself as an actor that wants to do something on each turn
func register(callback: Callable, done_signal: Signal) -> void:
	assert(callback is Callable)
	assert(done_signal is Signal)
	if callback in _callbacks:
		push_error("Already registered")
	else:
		_callbacks.append(callback)
	if done_signal.is_connected(_on_turn_taker_done):
		push_error("Already registered")
	else:
		done_signal.connect(_on_turn_taker_done)


## Cleanup before you die by unregistering yourself from the turn order
func unregister(callback: Callable, done_signal: Signal) -> void:
	assert(callback is Callable)
	assert(done_signal is Signal)
	if not callback in _callbacks:
		push_warning("Not registered")
	else:
		_callbacks.erase(callback)
	if done_signal.is_connected(_on_turn_taker_done):
		done_signal.disconnect(_on_turn_taker_done)
	else:
		push_error("Not registered")


## Call each actor in the turn order
func start_turn() -> void:
	_current_turn += 1
	Events.turn_started.emit(_current_turn)
	_actors_this_turn = _callbacks.size()
	if _actors_this_turn == 0:
		#push_warning("No actors on scene?")
		return
	_done_counter = 0
	for c:Callable in _callbacks:
		if c.is_valid():
			c.call()
		else:
			_done_counter += 1  # To avoid turn never finishing
			push_error("Turn taker is not callable. Should have unregistered?")


# Reaction to each individual actor saying they are done
# Emits turn_completed when all are done
func _on_turn_taker_done() -> void:
	_done_counter += 1
	if _done_counter >= _actors_this_turn:
		Events.turn_completed.emit(_current_turn)
