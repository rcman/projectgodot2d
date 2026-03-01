extends Node2D

enum ItemType { AMMO, HEALTH, ARMOR, KEY, EMPTY }

@export var item_type: ItemType = ItemType.AMMO
@export var is_searched: bool = false

@onready var sprite: ColorRect = $Sprite
@onready var door: ColorRect = $Door
@onready var interaction_area: Area2D = $InteractionArea

var item_colors = {
	ItemType.AMMO: Color(0.8, 0.6, 0.2, 1),
	ItemType.HEALTH: Color(0.2, 0.8, 0.2, 1),
	ItemType.ARMOR: Color(0.3, 0.3, 0.8, 1),
	ItemType.KEY: Color(0.9, 0.8, 0.1, 1),
	ItemType.EMPTY: Color(0.3, 0.3, 0.3, 1)
}

func _ready() -> void:
	# Randomize contents if not set
	if not is_searched:
		randomize_contents()

func randomize_contents() -> void:
	var rand = randf()
	if rand < 0.3:
		item_type = ItemType.AMMO
	elif rand < 0.5:
		item_type = ItemType.HEALTH
	elif rand < 0.65:
		item_type = ItemType.ARMOR
	elif rand < 0.75:
		item_type = ItemType.KEY
	else:
		item_type = ItemType.EMPTY

func search() -> void:
	if is_searched:
		return

	is_searched = true

	# Open door animation
	var tween = create_tween()
	tween.tween_property(door, "rotation_degrees", -90, 0.3)

	# Give item to player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		match item_type:
			ItemType.AMMO:
				player.add_ammo(10)
				show_pickup_text("+10 Ammo")
			ItemType.HEALTH:
				player.heal(2)
				show_pickup_text("+2 Health")
			ItemType.ARMOR:
				player.add_armor(25)
				show_pickup_text("+25 Armor")
			ItemType.KEY:
				player.add_key()
				show_pickup_text("+1 Key")
			ItemType.EMPTY:
				show_pickup_text("Empty")

	# Update sprite color to show contents
	sprite.color = item_colors[item_type]

func show_pickup_text(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.position = Vector2(-30, -60)
	label.add_theme_color_override("font_color", item_colors[item_type])
	add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "position:y", -100, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0, 1.0)
	tween.tween_callback(label.queue_free)
