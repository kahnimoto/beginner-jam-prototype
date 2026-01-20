extends Control


@onready var has_key_hud: TextureRect = %HasKeyHud
@onready var value_turn: Label = %ValueTurn
@onready var sandbags: Control = %Sandbags
@onready var bridge_parts: TextureRect = %BridgeParts


func _ready() -> void:
	_reset_inventory()
	Events.has_key_changed.connect(_on_has_key_changed)
	Events.turn_started.connect(_on_turn_started)
	Events.turn_completed.connect(_on_turn_completed)
	Events.sandbags_changed.connect(_on_sandbags_changed)
	Events.bridge_picked_up.connect(_on_bridge_parts_changed.bind(true))
	Events.bridge_used.connect(_on_bridge_parts_changed.bind(false))


# Refresh entire inventory display
func _reset_inventory() -> void:
	# Assumes player starts each level with empty inventory
	_on_sandbags_changed(0)
	bridge_parts.hide()
	has_key_hud.hide()


func _on_turn_started(t: int) -> void:
	value_turn.text = str(t)
	value_turn.modulate = Color.LIGHT_CORAL


func _on_turn_completed(t: int) -> void:
	value_turn.text = str(t)
	value_turn.modulate = Color.WHITE


func _on_bridge_parts_changed(new_value: bool) -> void:
	bridge_parts.visible = new_value


func _on_has_key_changed(new_value: bool) -> void:
	has_key_hud.visible = new_value


func _on_sandbags_changed(new_value: int) -> void:
	var icons: Array[Node] = sandbags.get_children()
	icons[0].visible = new_value >= 1
	icons[1].visible = new_value >= 2
	icons[2].visible = new_value >= 3
