class_name Doorway
extends Node2D


enum Dir { NORTH, EAST, SOUTH, WEST }

@export var direction_to_door: Dir = Dir.NORTH

@onready var spotlight: PointLight2D = $Spotlight


func _ready() -> void:
	Events.key_picked_up.connect(_on_key_picked_up)


## Doors are meant to open, if u have the key
func open() -> bool:
	return GameManager.open_door()


func _on_key_picked_up() -> void:
	match direction_to_door:
		Dir.NORTH:
			spotlight.position += Vector2.UP * Map.tile_size
		Dir.EAST:
			spotlight.position += Vector2.RIGHT * Map.tile_size
		Dir.SOUTH:
			spotlight.position += Vector2.DOWN * Map.tile_size
		Dir.WEST:
			spotlight.position += Vector2.LEFT * Map.tile_size
	spotlight.show()
