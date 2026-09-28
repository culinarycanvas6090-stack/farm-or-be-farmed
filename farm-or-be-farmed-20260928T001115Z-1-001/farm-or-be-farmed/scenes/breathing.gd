extends AudioStreamPlayer2D

@export var audio_length: float = 28.73

func _ready() -> void:
	play()
	await get_tree().create_timer(audio_length).timeout
	loop_audio()

func loop_audio() -> void:
	play()
	await get_tree().create_timer(audio_length).timeout
	loop_audio()
