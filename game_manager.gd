extends Node

var score: int = 0
var enemies_defeated: int = 0

func _ready() -> void:
	add_to_group("game_manager")

func add_score(points: int) -> void:
	score += points

func enemy_killed() -> void:
	enemies_defeated += 1
	add_score(100)

func get_score() -> int:
	return enemies_defeated

func game_over() -> void:
	# Small delay before showing game over
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://game_over.tscn")

func reset() -> void:
	score = 0
	enemies_defeated = 0
