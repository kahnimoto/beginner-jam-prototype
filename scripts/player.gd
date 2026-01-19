class_name Player
extends Node2D


#region variables
signal move_ended(at: Vector2i)

@export var grid_position: Vector2i

var _paused := false
var _is_moving := false
var _ended_on_ice := false
var _last_moved_direction := Vector2.ZERO

@onready var sprite: Sprite2D = %CharacterSprite
@onready var player_area: Area2D = $Area2D
@onready var shadow: Sprite2D = $Shadow
@onready var animation: AnimationPlayer = $AnimationPlayer
#endregion


func _ready() -> void:
	Events.new_pit_created.connect(_on_new_pit_created)
	Events.turn_completed.connect(func(_at): _is_moving = false)
	player_area.area_entered.connect(_on_player_area_entered)
	grid_position = (global_position / 16) as Vector2i
	animation.play("idle")


func _process(_delta: float) -> void:
	if not _is_moving and not _paused:
		move_character()


## Check for User input and move the character
## Triggers animation as well as starts the turn for the world
func move_character() -> void:
	var desired_movement: Vector2
	if _ended_on_ice:
		desired_movement = _last_moved_direction
	else:
		desired_movement = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if desired_movement.x != 0.0 and desired_movement.y != 0.0:
			return
		if desired_movement == Vector2.ZERO:
			return
	_last_moved_direction = desired_movement
	var desired_location: Vector2i = grid_position + (desired_movement as Vector2i)
	if Map.is_wall(desired_location):
		# TODO add some rejection animation and sound
		return
	Events.player_initiated_turn.emit()
	Events.play_left_square.emit(grid_position)
	_is_moving = true
	if (desired_movement.x < 0 and not sprite.flip_h) or (desired_movement.x > 0 and sprite.flip_h):
		sprite.flip_h = not sprite.flip_h
	
	grid_position += desired_movement as Vector2i
	_ended_on_ice = Map.is_ice(grid_position) and not GameManager.use_sand()
	var desired_global_pos: Vector2 = global_position + desired_movement * Map.tile_size
	var move_duration: float = TurnManager.TURN_DURATION
	var tween := create_tween()
	tween.tween_property(self, "global_position", desired_global_pos, move_duration).set_ease(Tween.EASE_IN)
	tween.tween_callback(move_ended.emit.bind(desired_location))


## Pause player activity and start death animation
func die() -> void:
	_paused = true
	animation.play("die")


## Callback used by animation to tell us we are game over
func dead() -> void:
	Events.level_failed.emit()


## Fall if you cant build a bridge
func fall_or_build() -> void:
	if GameManager.use_bridge():
		Map.change_to_bridge(grid_position, _last_moved_direction)
	else:
		fall()


## Stop player actions and start falling
func fall() -> void:
	_paused = true
	animation.play("fall")


## Callback used by animation to tell us we are game over
func fall_complete() -> void:
	Events.level_failed.emit()
	

# how do we react when a pit is created where we stand? we fall!
func _on_new_pit_created(location: Vector2i) -> void:
	if location == grid_position:
		fall()


# What did we walk into?
func _on_player_area_entered(other: Area2D) -> void:
	var other_parent = other.get_parent()
	if other_parent is Pickups:
		other_parent.pick_up()
	elif other_parent is Doorway:
		_paused = other_parent.open()
	elif other_parent is Monster:
		die()
	else:
		push_error("Collided with something unexpected!")
