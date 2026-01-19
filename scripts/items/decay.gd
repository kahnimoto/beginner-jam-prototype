class_name Decay
extends Node2D


signal _turn_done

@export var decay_in_turns: int = 5

var _tween: Tween
var _grid_position: Vector2i
var _turn: int = 0
var _turn_callable: Callable = Callable(self, "turn")
var _complete_callable: Callable

@onready var sprite: Sprite2D = $Sprite2D
@onready var countdown: Label = $ValueCountdown


## Star off the decay object with position and decay turns defined by map
func start(_pos: Vector2i, turns: int, complete_callable: Callable) -> void:
	_grid_position = _pos
	decay_in_turns = turns
	_turn = turns
	if _turn == 0:
		countdown.hide()
		sprite.modulate = Color(0, 0, 0, 0.5)
	else:
		countdown.text = str(_turn)
	_complete_callable = complete_callable
	GameManager.register(_turn_callable, _turn_done)


## This is the callback we send the turn manage with what we want to do each round
func turn() -> void:
	countdown.text = str(_turn)
	if _turn == 0:
		countdown.hide()
	_tween = create_tween()
	var alpha_per_turn: float = 0.5 / decay_in_turns
	var alpha: float = clampf(sprite.modulate.a + alpha_per_turn, 0.0, 1.0)
	var animation_duration: float = TurnManager.TURN_DURATION
	_tween.parallel().tween_property(sprite, "modulate", Color(0, 0, 0, alpha), animation_duration)
	_tween.tween_callback(_turn_done.emit)
	_turn -= 1
	if _turn < 0:
		_tween.tween_callback(_cleanup)


# Automatically unregister from turnorder and destroys itself
func _cleanup() -> void:
	_complete_callable.call()
	GameManager.unregister(_turn_callable, _turn_done)
	sprite.hide()
	queue_free.call_deferred()
