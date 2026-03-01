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
