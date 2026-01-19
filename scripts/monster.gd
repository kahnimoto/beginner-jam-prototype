class_name Monster
extends Node2D


signal turn_complete

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $SpriteHolder/Sprite2D


var _current_path_target: int = 0
var _grid_position: Vector2i
var _is_falling := false
var _path_nodes: Array[Vector2]
var _turn_callable: Callable


func _ready() -> void:
	_grid_position = Map.global_to_map(global_position)

	# If we have path markers, create a movement plan and prepare
	# to register with turn manager when level is ready
	var path_nodes_parent: Node2D = $PathNodes
	if path_nodes_parent and path_nodes_parent.get_child_count() > 0:
		for child:Node in path_nodes_parent.get_children():
			if child is Marker2D:
				_path_nodes.append(child.global_position)
		_turn_callable = Callable(self, "turn")
		Events.level_changed.connect(_on_level_changed)

	Events.new_pit_created.connect(_on_new_pit_created)


## What do we do when we are standing on a hole? We fall
## Starts the animation and unregisters from turn.
func fall() -> void:
	if _is_falling:
		return
	_is_falling = true
	turn_complete.emit()
	GameManager.unregister(_turn_callable, turn_complete)
	animation.play("fall")


## Calback for fall animation when it is complete
func has_fallen() -> void:
	queue_free()



## Callable for each turn, were we move to the next node
func turn() -> void:
	var direction := _pick_direction()
	_grid_position += direction as Vector2i
	var tween: Tween = create_tween()
	var move_duration: float = TurnManager.TURN_DURATION
	tween.tween_property(self, "global_position", global_position + direction * Map.tile_size, move_duration)
	tween.parallel().tween_property(sprite, "frame", 9, move_duration).from(0)
	if Map.is_pit(_grid_position):
		tween.tween_interval(0.01)
		tween.tween_callback(fall)
	tween.tween_callback(turn_complete.emit)


# How to pick the turn? Look at the next path marker
func _pick_direction() -> Vector2:
	var dir = global_position.direction_to(_path_nodes[_current_path_target])
	if dir == Vector2.ZERO:
		_current_path_target = (_current_path_target + 1) % _path_nodes.size()
		dir = global_position.direction_to(_path_nodes[_current_path_target])
	if dir == Vector2.LEFT:
		sprite.flip_h = true
	elif dir == Vector2.RIGHT:
		sprite.flip_h = false
	return dir.normalized()


# New level? Register with the turn manager
func _on_level_changed():
	if not GameManager.register(_turn_callable, turn_complete):
		push_error("Registering too early!")


# A pit was created beneath us? We fly? No we fall
func _on_new_pit_created(location: Vector2i) -> void:
	if location == _grid_position:
		fall()
