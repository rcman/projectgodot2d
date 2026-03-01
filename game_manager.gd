extends Node

var score: int = 0
var enemies_defeated: int = 0
var total_enemies: int = 0
var current_level: int = 1
var total_levels: int = 3

func _ready() -> void:
	add_to_group("game_manager")
	add_to_group("level_manager")
	# Count enemies after scene is ready
	call_deferred("count_enemies")

func count_enemies() -> void:
	await get_tree().process_frame
	var enemies = get_tree().get_nodes_in_group("enemies")
	total_enemies = enemies.size()

func add_score(points: int) -> void:
	score += points

func enemy_killed() -> void:
	enemies_defeated += 1
	add_score(100)

	# Check if all enemies defeated
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() <= 1:  # The one being killed
		level_complete()

func level_complete() -> void:
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://level_complete.tscn")

func get_score() -> int:
	return enemies_defeated

func get_current_level() -> int:
	return current_level

func next_level() -> void:
	current_level += 1
	enemies_defeated = 0
	if current_level > total_levels:
		current_level = 1
	load_current_level()

func load_current_level() -> void:
	var level_path = "res://level_" + str(current_level) + ".tscn"
	get_tree().change_scene_to_file(level_path)

func restart_level() -> void:
	enemies_defeated = 0
	load_current_level()

func reset_game() -> void:
	current_level = 1
	score = 0
	enemies_defeated = 0

func game_over() -> void:
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://game_over.tscn")
