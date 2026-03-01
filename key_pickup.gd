extends Area2D

var bob_offset: float = 0.0
var start_y: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	start_y = position.y

func _process(delta: float) -> void:
	# Bobbing animation
	bob_offset += delta * 3.0
	position.y = start_y + sin(bob_offset) * 5.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("add_key"):
			body.add_key()
		else:
			body.keys += 1

		# Update HUD
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.update_keys(body.keys)

		# Play sound
		var sound_manager = get_tree().get_first_node_in_group("sound_manager")
		if sound_manager:
			sound_manager.play_sound("key")

		queue_free()
