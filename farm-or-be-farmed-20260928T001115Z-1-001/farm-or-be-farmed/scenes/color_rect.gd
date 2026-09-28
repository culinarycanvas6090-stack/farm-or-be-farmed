
extends ColorRect

@export var fade_time: float = 3.0

func _ready():
	# Start completely black/visible
	modulate.a = 1.0

	# Fade the ColorRect and everything under it
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)


func fade_out():
	# Fade the ColorRect and all its children back to black
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_time)

	await tween.finished
