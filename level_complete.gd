extends Control

@onready var title_label: Label = $VBoxContainer/Title
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var next_button: Button = $VBoxContainer/NextButton
@onready var menu_button: Button = $VBoxContainer/MenuButton

func _ready() -> void:
	next_button.pressed.connect(_on_next_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	var level_manager = get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		var level = level_manager.get_current_level()
		level_label.text = "Level " + str(level) + " Complete!"

		if level >= level_manager.total_levels:
			title_label.text = "YOU WIN!"
			next_button.text = "PLAY AGAIN"
		else:
			title_label.text = "LEVEL COMPLETE"
			next_button.text = "NEXT LEVEL"

func _on_next_pressed() -> void:
	var level_manager = get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		if level_manager.get_current_level() >= level_manager.total_levels:
			level_manager.reset_game()
		level_manager.next_level()

func _on_menu_pressed() -> void:
	var level_manager = get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		level_manager.reset_game()
	get_tree().change_scene_to_file("res://main_menu.tscn")
