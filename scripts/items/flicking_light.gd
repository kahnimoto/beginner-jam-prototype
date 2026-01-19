extends PointLight2D


@export var min_delay: float = 3.0
@export var max_delay: float = 6.0
@export var min_flick_duration: float = 0.1
@export var max_flick_duration: float = 0.45
@export var start_flick_energy: float = 1.6
@export var end_flick_energy: float = 2.2

var _default_energy: float
var _tw: Tween


func _ready() -> void:
	await get_tree().create_timer(randf_range(1.0, max_delay * 2)).timeout
	_default_energy = energy
	_flicker()


func _flicker() -> void:
	if _tw:
		_tw.kill()
	_tw = create_tween()
	_tw.set_loops(3)
	var t: float = randf_range(min_flick_duration, max_flick_duration)
	_tw.tween_property(self, "energy", end_flick_energy, t).from(start_flick_energy)
	_tw.tween_callback(func(): energy = _default_energy)
	_tw.tween_interval(randf_range(min_delay, max_delay))
	_tw.finished.connect(_flicker)
