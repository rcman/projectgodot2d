extends Area2D

@export var speed: float = 800.0
@export var damage: int = 1
@export var is_player_bullet: bool = true

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Auto-destroy after 3 seconds
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(queue_free)

	# Connect signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Set bullet color based on owner
	var sprite = $Sprite
	if is_player_bullet:
		sprite.color = Color(1, 0.8, 0, 1)  # Yellow for player
	else:
		sprite.color = Color(1, 0.2, 0.2, 1)  # Red for enemy

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if is_player_bullet:
		# Player bullet hits enemies
		if body.is_in_group("enemies"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
			queue_free()
		elif body is StaticBody2D:
			queue_free()
	else:
		# Enemy bullet hits player
		if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
			queue_free()
		elif body is StaticBody2D:
			queue_free()

func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if is_player_bullet:
		if parent and parent.is_in_group("enemies"):
			if parent.has_method("take_damage"):
				parent.take_damage(damage)
			queue_free()
	else:
		if parent and parent.is_in_group("player"):
			if parent.has_method("take_damage"):
				parent.take_damage(damage)
			queue_free()
