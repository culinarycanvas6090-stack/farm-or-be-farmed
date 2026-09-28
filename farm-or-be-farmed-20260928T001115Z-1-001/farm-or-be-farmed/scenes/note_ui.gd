extends Control

func _process(delta):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		close_note()

func close_note():
	visible = false
	get_tree().paused = false
