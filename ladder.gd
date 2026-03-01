extends Area2D

@export var ladder_height: float = 100.0

func _ready() -> void:
	# Set collision immediately
	var collision_shape = $CollisionShape2D
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, ladder_height)
	collision_shape.shape = shape

	# Build visuals after
	call_deferred("build_visuals")

func build_visuals() -> void:
	var visual = $Visual
	for child in visual.get_children():
		child.queue_free()

	var half_height = ladder_height / 2

	# Create rails
	var left_rail = ColorRect.new()
	left_rail.offset_left = -16
	left_rail.offset_top = -half_height
	left_rail.offset_right = -10
	left_rail.offset_bottom = half_height
	left_rail.color = Color(0.45, 0.3, 0.15, 1)
	visual.add_child(left_rail)

	var right_rail = ColorRect.new()
	right_rail.offset_left = 10
	right_rail.offset_top = -half_height
	right_rail.offset_right = 16
	right_rail.offset_bottom = half_height
	right_rail.color = Color(0.45, 0.3, 0.15, 1)
	visual.add_child(right_rail)

	# Create rungs
	var rung_spacing = 25.0
	var num_rungs = int(ladder_height / rung_spacing)
	var start_y = -half_height + 10

	for i in range(num_rungs):
		var rung = ColorRect.new()
		var y_pos = start_y + i * rung_spacing
		rung.offset_left = -10
		rung.offset_top = y_pos
		rung.offset_right = 10
		rung.offset_bottom = y_pos + 5
		rung.color = Color(0.55, 0.4, 0.2, 1)
		visual.add_child(rung)
