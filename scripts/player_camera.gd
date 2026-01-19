class_name PlayerCamera
extends Camera2D


func _ready() -> void:
	var tilemap: TileMapLayer = get_tree().get_first_node_in_group("tilemap")
	assert(tilemap)
	var bounds: Array[Vector2] = []
	bounds.append(Vector2(tilemap.get_used_rect().position * tilemap.tile_set.tile_size))
	bounds.append(Vector2(tilemap.get_used_rect().end * tilemap.tile_set.tile_size))
	update_limits(bounds)


## Only show the parts of the world with tiles on it.
func update_limits(bounds: Array[Vector2]) -> void:
	if bounds == []:
		return
	limit_top = int(bounds[0].y)
	limit_left = int(bounds[0].x)
	limit_right = int(bounds[1].x)
	limit_bottom = int(bounds[1].y)
