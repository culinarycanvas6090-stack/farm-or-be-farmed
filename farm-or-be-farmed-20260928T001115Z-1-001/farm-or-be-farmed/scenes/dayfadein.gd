
extends ColorRect

@export var fade_time: float = 3.0

func _ready():
	# Start completely visible
	modulate.a = 1.0

	# Fade everything
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)

	# Fade CanvasLayer children too
	for child in get_children():
		if child is CanvasLayer:
			_set_children_alpha(child, 1.0)


func _set_children_alpha(node: Node, alpha: float):
	for child in node.get_children():
		if child is CanvasItem:
			child.modulate.a = alpha

		if child.get_child_count() > 0:
			_set_children_alpha(child, alpha)


func fade_out():
	# Fade the main ColorRect
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_time)

	# Fade CanvasLayer children to visible
	for child in get_children():
		if child is CanvasLayer:
			_set_children_alpha(child, 1.0)

	await tween.finished
