extends CharacterBody2D

@export var speed: float = 100.0
@export var quiet_speed: float = 45.0

@export var normal_noise: float = 30.0
@export var quiet_noise: float = 5.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flashlight: PointLight2D = $Flashlight

var last_direction := Vector2.DOWN
var spinning := false

var current_noise: float = 0.0


func _physics_process(_delta: float) -> void:

	# Get movement
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	# Check if holding Shift
	var quiet_walking := Input.is_key_pressed(KEY_SHIFT)

	# Set speed and noise
	if quiet_walking:
		velocity = direction * quiet_speed
		current_noise = quiet_noise
	else:
		velocity = direction * speed
		current_noise = normal_noise

	# Stop making noise when standing still
	if direction == Vector2.ZERO:
		current_noise = 0.0

	move_and_slide()

	# Remember facing direction
	if direction != Vector2.ZERO:
		last_direction = direction

	# Point flashlight where the farmer is facing
	flashlight.rotation = last_direction.angle()

	# Toggle spinning
	if Input.is_action_just_pressed("spin"):
		spinning = not spinning

		if spinning:
			animated_sprite.play("spin")
		else:
			update_animation(direction)

	# Keep playing spin animation
	if spinning:
		animated_sprite.play("spin")
		return

	# Normal animation
	update_animation(direction)


func update_animation(direction: Vector2) -> void:

	if direction != Vector2.ZERO:
		last_direction = direction

	var animation_name: String

	if direction == Vector2.ZERO:
		animation_name = get_animation("idle", last_direction)
	else:
		animation_name = get_animation("walk", direction)

	animated_sprite.play(animation_name)


func get_animation(action: String, direction: Vector2) -> String:

	var x := direction.x
	var y := direction.y

	# UP
	if y < -0.5 and abs(x) < 0.5:
		animated_sprite.flip_h = false
		return "b_" + action

	# DOWN
	if y > 0.5 and abs(x) < 0.5:
		animated_sprite.flip_h = false
		return "f_" + action

	# LEFT / RIGHT
	if abs(x) > 0.5 and abs(y) < 0.5:
		animated_sprite.flip_h = x < 0
		return "s_" + action

	# UP-LEFT / UP-RIGHT
	if y < -0.5 and abs(x) > 0.5:
		animated_sprite.flip_h = x < 0
		return "ud_" + action

	# DOWN-LEFT / DOWN-RIGHT
	if y > 0.5 and abs(x) > 0.5:
		animated_sprite.flip_h = x < 0
		return "dd_" + action

	return "f_" + action
