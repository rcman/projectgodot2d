extends CharacterBody2D

@export var speed: float = 60.0
@export var chase_speed: float = 100.0
@export var detection_range: float = 500.0
@export var shoot_range: float = 400.0
@export var max_health: int = 15
@export var damage: int = 2
@export var shoot_cooldown: float = 0.8

var health: int
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int = 1
var player: Node2D = null
var is_chasing: bool = false
var can_shoot: bool = true
var is_enraged: bool = false

@onready var sprite: ColorRect = $Sprite
@onready var ray_left: RayCast2D = $RayLeft
@onready var ray_right: RayCast2D = $RayRight
@onready var floor_left: RayCast2D = $FloorLeft
@onready var floor_right: RayCast2D = $FloorRight
@onready var shoot_timer: Timer = $ShootTimer
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	add_to_group("bosses")
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

	update_health_bar()

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Check if player is in range
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		is_chasing = distance_to_player < detection_range

		# Shoot at player if in range
		if distance_to_player < shoot_range and can_shoot:
			shoot_at_player()

	if is_chasing and player:
		chase_player()
	else:
		patrol()

	# Update sprite color based on state
	if is_enraged:
		sprite.color = Color(1.0, 0.1, 0.1, 1)  # Bright red when enraged
	elif is_chasing:
		sprite.color = Color(0.8, 0.2, 0.3, 1)  # Red when chasing
	else:
		sprite.color = Color(0.6, 0.15, 0.2, 1)  # Dark red when patrolling

	move_and_slide()

func patrol() -> void:
	# Check for walls
	if ray_right.is_colliding() and direction == 1:
		direction = -1
	elif ray_left.is_colliding() and direction == -1:
		direction = 1

	# Check for edges
	if is_on_floor():
		if not floor_right.is_colliding() and direction == 1:
			direction = -1
		elif not floor_left.is_colliding() and direction == -1:
			direction = 1

	velocity.x = direction * speed
	sprite.scale.x = direction

func chase_player() -> void:
	if not player:
		return

	var dir_to_player = sign(player.global_position.x - global_position.x)

	if is_on_floor():
		if not floor_right.is_colliding() and dir_to_player == 1:
			velocity.x = 0
			return
		elif not floor_left.is_colliding() and dir_to_player == -1:
			velocity.x = 0
			return

	direction = dir_to_player
	var current_speed = chase_speed
	if is_enraged:
		current_speed *= 1.5
	velocity.x = direction * current_speed
	sprite.scale.x = direction

func shoot_at_player() -> void:
	if not player:
		return

	can_shoot = false
	shoot_timer.start()

	var dir_to_player = sign(player.global_position.x - global_position.x)

	# Boss shoots 3 bullets in a spread pattern
	var angles = [0, -0.2, 0.2]
	if is_enraged:
		angles = [0, -0.15, 0.15, -0.3, 0.3]  # 5 bullets when enraged

	for angle in angles:
		var bullet = preload("res://bullet.tscn").instantiate()
		bullet.position = global_position + Vector2(dir_to_player * 30, 0)
		bullet.direction = Vector2(dir_to_player, angle).normalized()
		bullet.is_player_bullet = false
		bullet.speed = 350.0
		bullet.damage = damage
		get_tree().current_scene.add_child(bullet)

	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager:
		sound_manager.play_sound("enemy_shoot")

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func update_health_bar() -> void:
	health_bar.value = float(health) / float(max_health) * 100.0

func take_damage(amount: int) -> void:
	health -= amount
	update_health_bar()

	# Flash white briefly
	sprite.color = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.1).timeout

	# Become enraged at low health
	if health <= max_health / 3 and not is_enraged:
		is_enraged = true
		shoot_timer.wait_time = shoot_cooldown * 0.5  # Shoot faster

	if health <= 0:
		die()

func die() -> void:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.enemy_killed()
		game_manager.add_score(500)  # Bonus points for boss

	# Drop a key
	drop_key()

	# Death effect
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.5)
	await tween.finished
	queue_free()

func drop_key() -> void:
	var key_pickup = preload("res://key_pickup.tscn").instantiate()
	key_pickup.global_position = global_position + Vector2(0, 20)
	get_tree().current_scene.call_deferred("add_child", key_pickup)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
