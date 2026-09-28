extends ColorRect


func _ready():
	# Start black
	modulate.a = 1.0
	
	# FADE IN - 3 seconds
	var fade_in = create_tween()
	fade_in.tween_property(self, "modulate:a", 0.0, 3.0)
	await fade_in.finished
	
	# WAIT - 3 seconds
	await get_tree().create_timer(3.0).timeout
	
	# FADE OUT - 3 seconds
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 1.0, 3.0)
	await fade_out.finished
	
	# CHANGE SCENE
	get_tree().change_scene_to_file("res://scenes/day1.tscn")
	pass
