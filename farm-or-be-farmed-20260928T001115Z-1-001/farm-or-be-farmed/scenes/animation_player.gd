extends AnimationPlayer

@export var next_scene: String = "res://scenes/maze.tscn"
@export var animation_name: String = "falling"

func _ready() -> void:
	play(animation_name)
	await animation_finished
	get_tree().change_scene_to_file(next_scene)
