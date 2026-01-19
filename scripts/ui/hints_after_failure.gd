extends CanvasLayer


func _ready() -> void:
	hide()
	Events.level_failed.connect(show)
