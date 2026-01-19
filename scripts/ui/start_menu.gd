extends Control


@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	start_button.grab_focus()
	if OS.get_name() == "Web":
		quit_button.hide()
	else:
		quit_button.pressed.connect(get_tree().quit)


func _on_start_button_pressed() -> void:
	GameManager.new_game()
