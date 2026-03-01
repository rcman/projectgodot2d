extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/Label
@onready var ammo_label: Label = $AmmoLabel
@onready var armor_label: Label = $ArmorLabel
@onready var key_label: Label = $KeyLabel
@onready var score_label: Label = $ScoreLabel
@onready var level_label: Label = $LevelLabel
@onready var interaction_prompt: Label = $InteractionPrompt

var player: Node2D = null
var game_manager: Node = null

func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	game_manager = get_tree().get_first_node_in_group("game_manager")
	interaction_prompt.visible = false

func _process(_delta: float) -> void:
	if player:
		health_bar.value = player.health
		health_bar.max_value = player.max_health
		health_label.text = str(player.health) + "/" + str(player.max_health)
		ammo_label.text = "Ammo: " + str(player.ammo)
		armor_label.text = "Armor: " + str(player.armor)
		key_label.text = "Keys: " + str(player.keys)

	if game_manager:
		score_label.text = "Defeated: " + str(game_manager.enemies_defeated)
		level_label.text = "Level " + str(game_manager.current_level)

func show_interaction(text: String) -> void:
	interaction_prompt.text = text
	interaction_prompt.visible = true

func hide_interaction() -> void:
	interaction_prompt.visible = false

func update_keys(count: int) -> void:
	key_label.text = "Keys: " + str(count)

func show_message(text: String) -> void:
	# Show a temporary message in the center of the screen
	var message_label = Label.new()
	message_label.text = text
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 24)
	message_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
	message_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	message_label.add_theme_constant_override("outline_size", 3)
	message_label.position = Vector2(400, 300)
	message_label.size = Vector2(480, 50)
	add_child(message_label)

	# Fade out after 3 seconds
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(message_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(message_label.queue_free)
