extends StaticBody2D

@export var platform_width: float = 200.0
@export var one_way: bool = true

func _ready() -> void:
	# Set collision immediately
	var collision_shape = $CollisionShape2D
	var shape = RectangleShape2D.new()
	shape.size = Vector2(platform_width, 32)
	collision_shape.shape = shape

	# Enable one-way collision (can pass through from below)
	collision_shape.one_way_collision = one_way

	# Build visuals after
	call_deferred("build_visuals")

func build_visuals() -> void:
	var visual = $Visual
	for child in visual.get_children():
		child.queue_free()

	var half_width = platform_width / 2

	# Top layer (lighter wood)
	var top = ColorRect.new()
	top.offset_left = -half_width
	top.offset_top = -16
	top.offset_right = half_width
	top.offset_bottom = -10
	top.color = Color(0.5, 0.35, 0.15, 1)
	visual.add_child(top)

	# Middle layer
	var middle = ColorRect.new()
	middle.offset_left = -half_width
	middle.offset_top = -10
	middle.offset_right = half_width
	middle.offset_bottom = 6
	middle.color = Color(0.4, 0.28, 0.12, 1)
	visual.add_child(middle)

	# Bottom layer (darker wood)
	var bottom = ColorRect.new()
	bottom.offset_left = -half_width
	bottom.offset_top = 6
	bottom.offset_right = half_width
	bottom.offset_bottom = 16
	bottom.color = Color(0.35, 0.22, 0.1, 1)
	visual.add_child(bottom)

	# Plank dividers
	var plank_spacing = 50.0
	var num_planks = int(platform_width / plank_spacing) + 1

	for i in range(num_planks):
		var plank = ColorRect.new()
		var x_pos = -half_width + i * plank_spacing
		plank.offset_left = x_pos
		plank.offset_top = -16
		plank.offset_right = x_pos + 2
		plank.offset_bottom = 16
		plank.color = Color(0.3, 0.2, 0.08, 1)
		visual.add_child(plank)

	# Edge caps
	var left_cap = ColorRect.new()
	left_cap.offset_left = -half_width
	left_cap.offset_top = -16
	left_cap.offset_right = -half_width + 4
	left_cap.offset_bottom = 16
	left_cap.color = Color(0.3, 0.2, 0.08, 1)
	visual.add_child(left_cap)

	var right_cap = ColorRect.new()
	right_cap.offset_left = half_width - 4
	right_cap.offset_top = -16
	right_cap.offset_right = half_width
	right_cap.offset_bottom = 16
	right_cap.color = Color(0.3, 0.2, 0.08, 1)
	visual.add_child(right_cap)
