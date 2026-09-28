extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _pressed() -> void:
	await $ColorRect.fade_out()
	get_tree().change_scene_to_file("res://scenes/info.tscn")
