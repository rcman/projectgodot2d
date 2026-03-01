extends Control

@onready var title_label: Label = $VBoxContainer/Title
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var next_button: Button = $VBoxContainer/NextButton
@onready var menu_button: Button = $VBoxContainer/MenuButton

func _ready() -> void:
	next_button.pressed.connect(_on_next_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	var level = LevelManager.get_current_level()
	level_label.text = "Level " + str(level) + " Complete!"

	if level >= LevelManager.total_levels:
		title_label.text = "YOU WIN!"
		next_button.text = "PLAY AGAIN"
	else:
		title_label.text = "LEVEL COMPLETE"
		next_button.text = "NEXT LEVEL"

func _on_next_pressed() -> void:
	if LevelManager.get_current_level() >= LevelManager.total_levels:
		LevelManager.reset_game()
	LevelManager.next_level()

func _on_menu_pressed() -> void:
	LevelManager.reset_game()
	get_tree().change_scene_to_file("res://main_menu.tscn")
