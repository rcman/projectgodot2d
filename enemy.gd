extends CharacterBody2D

@export var speed: float = 100.0
@export var chase_speed: float = 150.0
@export var detection_range: float = 300.0
@export var shoot_range: float = 250.0
@export var health: int = 3
@export var damage: int = 1
@export var shoot_cooldown: float = 1.5

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int = 1
var player: Node2D = null
var is_chasing: bool = false
var can_shoot: bool = true

@onready var sprite: ColorRect = $Sprite
@onready var ray_left: RayCast2D = $RayLeft
@onready var ray_right: RayCast2D = $RayRight
@onready var floor_left: RayCast2D = $FloorLeft
@onready var floor_right: RayCast2D = $FloorRight
@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	add_to_group("enemies")
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

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
	if is_chasing:
		sprite.color = Color(1.0, 0.2, 0.2, 1)  # Red when chasing
	else:
		sprite.color = Color(0.8, 0.2, 0.2, 1)  # Dark red when patrolling

	move_and_slide()

func patrol() -> void:
	var current_speed = speed

	# Check for walls
	if ray_right.is_colliding() and direction == 1:
		direction = -1
	elif ray_left.is_colliding() and direction == -1:
		direction = 1

	# Check for edges (no floor ahead)
	if is_on_floor():
		if not floor_right.is_colliding() and direction == 1:
			direction = -1
		elif not floor_left.is_colliding() and direction == -1:
			direction = 1

	velocity.x = direction * current_speed
	sprite.scale.x = direction

func chase_player() -> void:
	if not player:
		return

	var dir_to_player = sign(player.global_position.x - global_position.x)

	# Check for edges - don't fall off platforms while chasing
	if is_on_floor():
		if not floor_right.is_colliding() and dir_to_player == 1:
			velocity.x = 0
			return
		elif not floor_left.is_colliding() and dir_to_player == -1:
			velocity.x = 0
			return

	direction = dir_to_player
	velocity.x = direction * chase_speed
	sprite.scale.x = direction

func shoot_at_player() -> void:
	if not player:
		return

	can_shoot = false
	shoot_timer.start()

	var dir_to_player = sign(player.global_position.x - global_position.x)

	var bullet = preload("res://bullet.tscn").instantiate()
	bullet.position = global_position + Vector2(dir_to_player * 20, 0)
	bullet.direction = Vector2(dir_to_player, 0)
	bullet.is_player_bullet = false
	bullet.speed = 400.0
	get_tree().current_scene.add_child(bullet)

	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager:
		sound_manager.play_sound("enemy_shoot")

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func take_damage(amount: int) -> void:
	health -= amount

	# Flash white briefly
	sprite.color = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.1).timeout
	sprite.color = Color(0.8, 0.2, 0.2, 1)

	if health <= 0:
		die()

func die() -> void:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.enemy_killed()
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
