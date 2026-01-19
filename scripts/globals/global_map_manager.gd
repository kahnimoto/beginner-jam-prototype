extends Node


const TILE_WITH_PIT := Vector2i(9,6)
const TILE_WITH_BRIDGE := Vector2i(9,3)
const FLOOR_DELAY_DEFAULT := 2

var tile_size: int:
	get():
		return _tile_size
var _tile_size: int
var _tilemap: TileMapLayer


## Convert an entity's global position to their Map Cordinates
func global_to_map(global: Vector2) -> Vector2i:
	if not _tilemap:
		_grab_tilemap_from_active_scene()
	assert(_tilemap is TileMapLayer)
	var grid_position := (global / tile_size) as Vector2i
	return grid_position


## Convert an entit's map grid coordinates to a equivalient global position
func map_to_global(grid_position: Vector2i) -> Vector2i:
	if not _tilemap:
		_grab_tilemap_from_active_scene()
	assert(_tilemap is TileMapLayer)
	var actual_position := (grid_position * tile_size) as Vector2i
	return actual_position


## Check if the specified map coordinate is a wall
func is_wall(location: Vector2i) -> bool:
	return _check_for_bool_custom_data(location, "wall")


## Returns the number of turns this tile will stay after walked on
func get_tile_floor_delay(location: Vector2i) -> int:
	if not _tilemap:
		_grab_tilemap_from_active_scene()
	assert(_tilemap is TileMapLayer)
	var data := _tilemap.get_cell_tile_data(location)
	if not data:
		push_warning("Looking up data on a tile without data")
		return FLOOR_DELAY_DEFAULT
	var decay: int = data.get_custom_data("decay")
	return decay


## Change the tile at the specified location to a pit
func change_to_pit(location: Vector2i) -> void:
	if not _tilemap:
		_grab_tilemap_from_active_scene()
	assert(_tilemap is TileMapLayer)
	_tilemap.set_cell(location, 0, TILE_WITH_PIT)
	Events.new_pit_created.emit(location)


## Change the tile at location to a bridge
func change_to_bridge(location: Vector2i, _direction: Vector2 = Vector2.UP) -> void:
	if not _tilemap:
		_grab_tilemap_from_active_scene()
	assert(_tilemap is TileMapLayer)
	var rotated_tile =  TileSetAtlasSource.TRANSFORM_TRANSPOSE if _direction in [Vector2.LEFT, Vector2.RIGHT] else 0
	_tilemap.set_cell(location, 0, TILE_WITH_BRIDGE, rotated_tile)


## Check if the specified location in the map grid is a pit
func is_pit(location: Vector2i) -> bool:
	return _check_for_bool_custom_data(location, "pit")


## Check if the specified map coordinate is an ice tile
func is_ice(location: Vector2i) -> bool:
	return _check_for_bool_custom_data(location, "ice")


# Look up a custom data bool type
func _check_for_bool_custom_data(location: Vector2i, data_name: String) -> bool:
	if not _tilemap:
		_grab_tilemap_from_active_scene()
	assert(_tilemap is TileMapLayer)
	var data := _tilemap.get_cell_tile_data(location)
	if not data:
		push_warning("Why checking invalid location?")
		return false
	return data.get_custom_data(data_name)


# Ensure we have access to the current active tilmape in the level
func _grab_tilemap_from_active_scene() -> void:
	_tilemap = get_tree().get_first_node_in_group("dungeon")
	if _tilemap:
		assert(_tilemap is TileMapLayer)
		_tile_size = _tilemap.tile_set.tile_size.x  # TODO ASSUMES SQUARE GRIDS!
		assert(_tile_size > 0 and _tile_size < 1024)
