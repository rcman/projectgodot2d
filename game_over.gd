extends Control

@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var menu_button: Button = $VBoxContainer/MenuButton

var final_score: int = 0

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	# Get score from game manager if available
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("get_score"):
		final_score = game_manager.get_score()

	score_label.text = "Enemies Defeated: " + str(final_score)

	# Animate game over text
	animate_entrance()

func animate_entrance() -> void:
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _on_restart_pressed() -> void:
	LevelManager.restart_level()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
