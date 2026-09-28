
extends CanvasLayer

@onready var jumpscare_image: TextureRect = $TextureRect
@onready var sound_1: AudioStreamPlayer = $JumpscareSound1
@onready var sound_2: AudioStreamPlayer = $JumpscareSound2

@export var delay_between_sounds: float = 3.0
@export var delay_after_sound: float = 3.0

var triggered := false


func _ready() -> void:
	visible = false


func play_jumpscare() -> void:

	if triggered:
		return

	triggered = true

	# Show jumpscare
	visible = true
	jumpscare_image.visible = true

	# Stop the player/monster/game movement
	get_tree().paused = true

	# Play first sound
	sound_1.play()

	# Wait until the first sound finishes
	# Delay between sounds
	await get_tree().create_timer(
		delay_between_sounds,
		true,
		false,
		true
	).timeout

	# Play second sound
	sound_2.play()

	# Wait until second sound finishes


	# Extra delay after second sound
	await get_tree().create_timer(
		delay_after_sound,
		true,
		false,
		true
	).timeout

	# Restart the current scene
	get_tree().paused = false
	get_tree().reload_current_scene()
