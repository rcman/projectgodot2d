extends Control

@onready var title_label: Label = $VBoxContainer/Title
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Reset game state
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.reset_game()

	# Animate title
	animate_title()

func animate_title() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(title_label, "modulate:a", 0.7, 1.0)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://level_1.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
