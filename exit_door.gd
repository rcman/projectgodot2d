extends StaticBody2D

@export var is_locked: bool = true

var player_nearby: bool = false
var player_ref: Node2D = null

@onready var door_sprite: ColorRect = $DoorSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var lock_icon: ColorRect = $LockIcon
@onready var exit_sign: ColorRect = $ExitSign

func _ready() -> void:
	add_to_group("exit_door")
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	update_display()

func _process(_delta: float) -> void:
	if player_nearby and is_locked:
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
				hud.show_interaction("Press E to unlock exit")
			else:
				hud.show_interaction("EXIT - Need key")
		else:
			hud.show_interaction("Press E to exit level")

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
		update_display()
		play_sound("door_open")
		exit_level()
	else:
		play_sound("locked")

func exit_level() -> void:
	hide_prompt()

	# Animate door opening
	var tween = create_tween()
	tween.tween_property(door_sprite, "position:y", -150, 0.5).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(lock_icon, "modulate:a", 0, 0.2)

	await tween.finished
	collision_shape.set_deferred("disabled", true)

	# Trigger level complete
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.level_complete()

func update_display() -> void:
	if is_locked:
		lock_icon.visible = true
		door_sprite.color = Color(0.3, 0.5, 0.3, 1)  # Greenish locked
	else:
		lock_icon.visible = false
		door_sprite.color = Color(0.2, 0.8, 0.2, 1)  # Bright green unlocked

func unlock_door() -> void:
	is_locked = false
	update_display()

func play_sound(sound_name: String) -> void:
	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager:
		sound_manager.play_sound(sound_name)
