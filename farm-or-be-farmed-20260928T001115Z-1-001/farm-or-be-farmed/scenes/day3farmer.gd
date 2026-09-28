extends CharacterBody2D

@export var speed: float = 100.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

var objective_label: Label
var canvas_modulate: CanvasModulate

var last_direction := Vector2.DOWN
var spinning := false
var interacting := false
var day_complete := false

var pumpkins_picked := 0
var pumpkin_goal := 30


func _ready() -> void:

	# Find ObjectiveLabel anywhere in the current scene
	objective_label = get_tree().current_scene.find_child(
		"ObjectiveLabel",
		true,
		false
	) as Label

	if objective_label != null:
		objective_label.text = "Pick pumpkins: 0/30"
		print("ObjectiveLabel found!")
	else:
		print("ERROR: ObjectiveLabel was not found!")

	# Find CanvasModulate anywhere in the current scene
	canvas_modulate = get_tree().current_scene.find_child(
		"CanvasModulate",
		true,
		false
	) as CanvasModulate

	if canvas_modulate != null:
		canvas_modulate.color = Color.WHITE
		print("CanvasModulate found!")
	else:
		print("ERROR: CanvasModulate was not found!")


func _physics_process(_delta: float) -> void:

	# Don't move while interacting
	if interacting:
		velocity = Vector2.ZERO
		return

	# Toggle spinning
	if Input.is_action_just_pressed("spin"):
		spinning = not spinning

		if spinning:
			animated_sprite.play("spin")
		else:
			update_animation(Vector2.ZERO)

	# Keep spinning
	if spinning:
		velocity = Vector2.ZERO
		animated_sprite.play("spin")
		return

	# Movement
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * speed
	move_and_slide()

	# Interact
	if Input.is_action_just_pressed("interact"):
		if try_interact():
			return

	# Normal animation
	update_animation(direction)


func try_interact() -> bool:

	var objects := interaction_area.get_overlapping_areas()

	for object in objects:

		# Pumpkin
		if object.is_in_group("pumpkin"):
			pick_pumpkin(object)
			return true

		# Bed
		if object.is_in_group("bed"):

			if pumpkins_picked >= pumpkin_goal:
				go_to_bed()
			else:
				print("You need to pick all the pumpkins first!")

			return true

	return false


func pick_pumpkin(pumpkin: Area2D) -> void:

	interacting = true
	velocity = Vector2.ZERO

	# Get interaction animation
	var interact_animation := get_animation("interact", last_direction)

	print("Playing interaction: ", interact_animation)

	# Play picking animation
	animated_sprite.play(interact_animation)

	# Wait for picking animation
	await get_tree().create_timer(0.6).timeout

	# Increase pumpkin count
	pumpkins_picked += 1

	print("Pumpkins picked: ", pumpkins_picked)

	# Update objective
	if objective_label != null:

		if pumpkins_picked < pumpkin_goal:
			objective_label.text = "Pick pumpkins: %d/%d" % [
				pumpkins_picked,
				pumpkin_goal
			]

	# Remove pumpkin
	pumpkin.queue_free()

	# Check if we collected enough
	if pumpkins_picked >= pumpkin_goal:
		complete_pumpkin_objective()

	# Allow movement again
	interacting = false

	# Return to idle
	update_animation(Vector2.ZERO)


func complete_pumpkin_objective() -> void:

	day_complete = true

	print("PUMPKIN GOAL COMPLETE!")

	# Change objective
	if objective_label != null:
		objective_label.text = "Go to bed"

	# Fade screen to #C37E00
	if canvas_modulate != null:

		var target_color := Color("#c37e00")

		var tween := create_tween()

		tween.tween_property(
			canvas_modulate,
			"color",
			target_color,
			3.0
		)


func go_to_bed() -> void:

	print("Going to bed...")

	interacting = true
	velocity = Vector2.ZERO

	# Change objective
	if objective_label != null:
		objective_label.text = "Goodnight..."

	# Wait
	await get_tree().create_timer(2.0).timeout

	# CHANGE THIS PATH IF YOUR DAY 2 SCENE IS SOMEWHERE ELSE
	get_tree().change_scene_to_file("res://scenes/day4.tscn")


func update_animation(direction: Vector2) -> void:

	# Remember direction
	if direction != Vector2.ZERO:
		last_direction = direction.normalized()

	var animation_name: String

	# Idle
	if direction == Vector2.ZERO:
		animation_name = get_animation("idle", last_direction)

	# Walking
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

	# Default
	return "f_" + action
