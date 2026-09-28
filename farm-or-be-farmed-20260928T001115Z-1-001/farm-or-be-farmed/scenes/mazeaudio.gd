extends AudioStreamPlayer

@export var audio_length: float = 69.85

func _ready() -> void:
	play()
	await get_tree().create_timer(audio_length).timeout
	loop_audio()

func loop_audio() -> void:
	play()
	await get_tree().create_timer(audio_length).timeout
	loop_audio()
