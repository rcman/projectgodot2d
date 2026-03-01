extends ParallaxBackground

func _ready() -> void:
	# Background doesn't scroll - it's static
	scroll_ignore_camera_zoom = true

func _draw() -> void:
	pass  # Drawing handled by child nodes
