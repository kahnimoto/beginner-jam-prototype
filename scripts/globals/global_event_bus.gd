## Used in Globals as `Events`
class_name GlobalEventBus
extends Node


@warning_ignore_start("unused_signal")
# Game
signal game_wun
signal game_lost

# Map
signal level_completed
signal level_changed
signal level_failed
signal new_pit_created(pos: Vector2i)

# Items
signal has_key_changed(new_value: bool)
signal key_picked_up
signal key_used
signal sand_picked_up(new_count: int)
signal sand_used
signal bridge_picked_up
signal bridge_used

# Player
signal play_left_square(pos: Vector2i)
signal player_initiated_turn
signal player_slid

# Turn
signal turn_started(turn: int)
signal turn_completed(turn: int)

@warning_ignore_restore("unused_signal")
