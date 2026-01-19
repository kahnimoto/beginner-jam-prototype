extends Control


enum Message { WINNER, LOSER }

@export var type: Message = Message.WINNER


func _ready() -> void:
	hide()
	match type:
		Message.WINNER:
			Events.game_wun.connect(show)
		Message.LOSER:
			Events.level_failed.connect(show)
