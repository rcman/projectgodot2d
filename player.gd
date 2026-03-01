extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var climb_speed: float = 200.0
@export var max_health: int = 5
@export var max_ammo: int = 30

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_on_ladder: bool = false
var ladders_overlapping: int = 0
var can_shoot: bool = true
var shoot_cooldown: float = 0.3
var health: int
var ammo: int = 30
var armor: int = 0
var keys: int = 0
var is_invincible: bool = false
var invincibility_time: float = 1.0
var nearby_locker: Node2D = null
var is_dead: bool = false

@onready var sprite: ColorRect = $Sprite
@onready var shoot_timer: Timer = $ShootTimer
@onready var ladder_detector: Area2D = $LadderDetector
@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	health = max_health
	add_to_group("player")
	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

	ladder_detector.area_entered.connect(_on_ladder_entered)
	ladder_detector.area_exited.connect(_on_ladder_exited)

	interaction_area.area_entered.connect(_on_interaction_entered)
	interaction_area.area_exited.connect(_on_interaction_exited)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	var can_climb = ladders_overlapping > 0
	var vertical_input = Input.get_axis("ui_up", "ui_down")

	# More forgiving ladder entry
	if can_climb and not is_on_ladder:
		if vertical_input != 0:
			is_on_ladder = true
			velocity.y = 0
		elif velocity.y > 100 and Input.is_action_pressed("ui_up"):
			is_on_ladder = true
			velocity.y = 0

	# Handle gravity
	if not is_on_floor() and not is_on_ladder:
		velocity.y += gravity * delta

	# Ladder climbing
	if is_on_ladder:
		if can_climb:
			velocity.y = vertical_input * climb_speed
			var h_input = Input.get_axis("ui_left", "ui_right")
			velocity.x = h_input * speed * 0.3

			if Input.is_action_just_pressed("ui_accept"):
				is_on_ladder = false
				velocity.y = jump_velocity * 0.7
				play_sound("jump")
		else:
			is_on_ladder = false
	else:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity
			play_sound("jump")

		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * speed
			sprite.scale.x = sign(direction)
		else:
			velocity.x = move_toward(velocity.x, 0, speed * 0.2)

	if Input.is_action_just_pressed("shoot") and can_shoot and ammo > 0:
		shoot()

	if Input.is_action_just_pressed("interact") and nearby_locker:
		nearby_locker.search()
		play_sound("locker")

	move_and_slide()

func shoot() -> void:
	can_shoot = false
	ammo -= 1
	shoot_timer.start()
	play_sound("shoot")

	var bullet = preload("res://bullet.tscn").instantiate()
	bullet.position = global_position + Vector2(sprite.scale.x * 20, 0)
	bullet.direction = Vector2(sprite.scale.x, 0)
	bullet.is_player_bullet = true
	get_tree().current_scene.add_child(bullet)

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func _on_ladder_entered(area: Area2D) -> void:
	if area.is_in_group("ladders"):
		ladders_overlapping += 1

func _on_ladder_exited(area: Area2D) -> void:
	if area.is_in_group("ladders"):
		ladders_overlapping -= 1
		if ladders_overlapping <= 0:
			ladders_overlapping = 0
			is_on_ladder = false

func _on_interaction_entered(area: Area2D) -> void:
	if area.is_in_group("lockers"):
		nearby_locker = area.get_parent()
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.show_interaction("Press E to search")

func _on_interaction_exited(area: Area2D) -> void:
	if area.is_in_group("lockers"):
		nearby_locker = null
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.hide_interaction()

func take_damage(amount: int) -> void:
	if is_invincible or is_dead:
		return

	play_sound("hurt")

	if armor > 0:
		var armor_damage = min(armor, amount)
		armor -= armor_damage
		amount -= armor_damage

	if amount > 0:
		health -= amount

	is_invincible = true
	flash_damage()

	if health <= 0:
		die()
	else:
		await get_tree().create_timer(invincibility_time).timeout
		is_invincible = false
		sprite.color = Color(0.2, 0.6, 0.9, 1)

func flash_damage() -> void:
	for i in range(5):
		sprite.color = Color(1, 0.3, 0.3, 1)
		await get_tree().create_timer(0.1).timeout
		sprite.color = Color(0.2, 0.6, 0.9, 1)
		await get_tree().create_timer(0.1).timeout

func die() -> void:
	if is_dead:
		return

	is_dead = true
	play_sound("die")
	velocity = Vector2.ZERO

	# Death animation
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(self, "position:y", position.y - 50, 0.5)

	# Trigger game over
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.game_over()

func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	play_sound("pickup")

func add_ammo(amount: int) -> void:
	ammo = min(ammo + amount, max_ammo)
	play_sound("pickup")

func add_armor(amount: int) -> void:
	armor = min(armor + amount, 100)
	play_sound("pickup")

func add_key() -> void:
	keys += 1
	play_sound("key")

func play_sound(sound_name: String) -> void:
	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager:
		sound_manager.play_sound(sound_name)
