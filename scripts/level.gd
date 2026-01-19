class_name Level
extends Node


const DECAY_SCENE = preload("uid://gfv2617xrpoh")

@export var map_offset: Vector2i = Vector2i(5, 2)

var _active_decays: Array[Vector2i] = []

@onready var dungeon: TileMapLayer = %DungeonBackground
@onready var player: Player = %Player
@onready var world: Node2D = $World


func _ready() -> void:
	assert(dungeon is TileMapLayer)
	assert(player is Player)
	assert(world is Node2D)
	Events.play_left_square.connect(_on_player_left_square)
	player.move_ended.connect(_on_player_entered_square)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		GameManager.restart_level()


func _on_player_entered_square(location: Vector2i) -> void:
	if Map.is_pit(location):
		player.fall_or_build()


func _on_decay_completed(location: Vector2i) -> void:
	Map.change_to_pit(location)


func _on_player_left_square(location: Vector2i) -> void:
	var decay_turns = Map.get_tile_floor_delay(location)
	if decay_turns < 0:
		return
	if location in _active_decays:
		return
	_active_decays.append(location)
	var decay: Decay = DECAY_SCENE.instantiate() as Decay
	var global_pos = Map.map_to_global(location)
	world.add_child(decay)
	decay.global_position = global_pos
	decay.start(location, decay_turns, Callable(self, "_on_decay_completed").bind(location))
