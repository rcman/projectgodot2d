extends StaticBody2D

@export var is_locked: bool = true
@export var is_open: bool = false

var player_nearby: bool = false
var player_ref: Node2D = null

@onready var door_sprite: ColorRect = $DoorSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var lock_icon: ColorRect = $LockIcon

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	update_lock_display()

func _process(_delta: float) -> void:
	if player_nearby and is_locked and not is_open:
		if Input.is_action_just_pressed("interact"):
			try_unlock()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		player_ref = body
		show_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		player_ref = null
		hide_prompt()

func show_prompt() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		if is_locked:
			if player_ref and player_ref.keys > 0:
				hud.show_interaction("Press E to unlock")
			else:
				hud.show_interaction("Locked - Need key")
		elif not is_open:
			hud.show_interaction("Press E to open")

func hide_prompt() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.hide_interaction()

func try_unlock() -> void:
	if not player_ref:
		return

	if player_ref.keys > 0:
		player_ref.keys -= 1
		is_locked = false
		update_lock_display()
		open_door()
		play_sound("key")
	else:
		play_sound("locked")

func open_door() -> void:
	if is_open:
		return

	is_open = true
	hide_prompt()

	# Animate door opening (slide up)
	var tween = create_tween()
	tween.tween_property(door_sprite, "position:y", -150, 0.5).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(lock_icon, "modulate:a", 0, 0.2)

	# Disable collision
	await tween.finished
	collision_shape.set_deferred("disabled", true)

func update_lock_display() -> void:
	if is_locked:
		lock_icon.visible = true
		lock_icon.color = Color(0.8, 0.2, 0.2, 1)
	else:
		lock_icon.visible = false

func play_sound(sound_name: String) -> void:
	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager:
		sound_manager.play_sound(sound_name)
