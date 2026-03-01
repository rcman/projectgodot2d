extends Node

var current_level: int = 1
var total_levels: int = 6
var enemies_remaining: int = 0

# Persistent player stats across levels
var saved_armor_level: int = 0
var saved_armor_percent: int = 0

signal level_complete
signal all_levels_complete

func _ready() -> void:
	add_to_group("level_manager")

func set_enemy_count(count: int) -> void:
	enemies_remaining = count

func enemy_killed() -> void:
	enemies_remaining -= 1
	if enemies_remaining <= 0:
		emit_signal("level_complete")

func get_current_level() -> int:
	return current_level

func next_level() -> void:
	current_level += 1
	if current_level > total_levels:
		emit_signal("all_levels_complete")
	else:
		load_current_level()

func load_current_level() -> void:
	var level_path = "res://level_" + str(current_level) + ".tscn"
	get_tree().change_scene_to_file(level_path)

func restart_level() -> void:
	load_current_level()

func reset_game() -> void:
	current_level = 1
	saved_armor_level = 0
	saved_armor_percent = 0
