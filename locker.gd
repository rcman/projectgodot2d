extends Node2D

enum ItemType { AMMO, HEALTH, ARMOR, KEY, EMPTY }

@export var item_type: ItemType = ItemType.AMMO
@export var is_searched: bool = false

@onready var sprite: ColorRect = $Sprite
@onready var door: Node2D = $Door
@onready var interaction_area: Area2D = $InteractionArea

var item_colors = {
	ItemType.AMMO: Color(0.8, 0.6, 0.2, 1),
	ItemType.HEALTH: Color(0.2, 0.8, 0.2, 1),
	ItemType.ARMOR: Color(0.3, 0.3, 0.8, 1),
	ItemType.KEY: Color(0.9, 0.8, 0.1, 1),
	ItemType.EMPTY: Color(0.3, 0.3, 0.3, 1)
}

func _ready() -> void:
	if not is_searched:
		randomize_contents()

func randomize_contents() -> void:
	var rand = randf()
	if rand < 0.35:
		item_type = ItemType.AMMO
	elif rand < 0.65:
		item_type = ItemType.HEALTH
	elif rand < 0.80:
		item_type = ItemType.ARMOR
	elif rand < 0.90:
		item_type = ItemType.KEY
	else:
		item_type = ItemType.EMPTY

func search() -> void:
	if is_searched:
		return

	is_searched = true

	# Open door animation - swing open
	var tween = create_tween()
	tween.tween_property(door, "rotation_degrees", -120, 0.4).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(door, "position:x", -30, 0.4)

	# Give item to player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		match item_type:
			ItemType.AMMO:
				player.add_ammo(15)
				show_pickup_text("+15 Ammo")
			ItemType.HEALTH:
				player.heal(25)
				show_pickup_text("+25 Health")
			ItemType.ARMOR:
				player.add_armor(25)
				show_pickup_text("+25% Armor")
			ItemType.KEY:
				player.add_key()
				show_pickup_text("+1 Key")
			ItemType.EMPTY:
				show_pickup_text("Empty")

	# Show item inside locker
	show_item_inside()

func show_item_inside() -> void:
	if item_type == ItemType.EMPTY:
		return

	var item_visual = ColorRect.new()
	item_visual.offset_left = -10
	item_visual.offset_top = -10
	item_visual.offset_right = 10
	item_visual.offset_bottom = 10
	item_visual.color = item_colors[item_type]
	sprite.add_child(item_visual)
	item_visual.position = Vector2(25, 35)

	# Fade out the item
	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(item_visual, "modulate:a", 0, 0.5)
	tween.tween_callback(item_visual.queue_free)

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
