extends Control

@onready var bar: ColorRect = $Bar

var farmer
var noise_level: float = 0.0


func _ready() -> void:
	# Find the Farmer anywhere in the current scene
	farmer = get_tree().current_scene.find_child("Farmer", true, false)

	if farmer == null:
		print("ERROR: Could not find Farmer!")
	else:
		print("Noise Meter found Farmer!")


func _process(delta: float) -> void:
	if farmer == null:
		return

	# Get the Farmer's noise
	var target_noise: float = farmer.current_noise

	# Smoothly change the meter
	noise_level = move_toward(
		noise_level,
		target_noise,
		100.0 * delta
	)

	# Change the bar width
	bar.size.x = noise_level * 2.0
