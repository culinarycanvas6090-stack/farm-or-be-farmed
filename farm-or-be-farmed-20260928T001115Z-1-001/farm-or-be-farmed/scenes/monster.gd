extends CharacterBody2D

@export var wander_speed: float = 25.0
@export var chase_speed: float = 70.0
@export var hearing_range: float = 250.0
@export var noise_needed: float = 10.0

@export var wander_min_time: float = 2.0
@export var wander_max_time: float = 5.0

@export var stuck_time: float = 1.5
@export var minimum_wander_distance: float = 100.0

@export var jumpscare_distance: float = 25.0


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


var player: CharacterBody2D
var chasing := false

var wander_timer := 0.0
var stuck_timer := 0.0

var last_position := Vector2.ZERO

var navigation_map: RID

var jumpscare


func _ready() -> void:

	randomize()

	# Find player
	player = get_tree().get_first_node_in_group("player")

	# Find jumpscare CanvasLayer
	jumpscare = get_tree().get_first_node_in_group("jumpscare")

	# Get navigation map
	navigation_map = get_world_2d().navigation_map

	# Wait for navigation to initialize
	await get_tree().physics_frame
	await get_tree().physics_frame

	# NavigationAgent settings
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 6.0
	navigation_agent.radius = 8.0
	navigation_agent.avoidance_enabled = true

	last_position = global_position

	# Start wandering
	pick_new_wander_target()


func _physics_process(delta: float) -> void:

	if player == null:
		player = get_tree().get_first_node_in_group("player")

		if player == null:
			return


	# Distance from monster to player
	var distance_to_player := global_position.distance_to(
		player.global_position
	)

	# Get player's current noise
	var player_noise: float = player.current_noise


	# --------------------------------
	# JUMPSCARE
	# --------------------------------

	if distance_to_player <= jumpscare_distance:

		trigger_jumpscare()
		return


	# --------------------------------
	# HEAR PLAYER
	# --------------------------------

	if distance_to_player <= hearing_range and player_noise >= noise_needed:

		chasing = true


	# --------------------------------
	# CHASE
	# --------------------------------

	if chasing:

		chase_player()

	# --------------------------------
	# WANDER
	# --------------------------------

	else:

		wander(delta)


	# --------------------------------
	# CHECK IF STUCK
	# --------------------------------

	check_if_stuck(delta)


# ========================================
# CHASE PLAYER
# ========================================

func chase_player() -> void:

	# Update target to player's current position
	navigation_agent.target_position = player.global_position


	# If we reached the player
	if navigation_agent.is_navigation_finished():

		velocity = Vector2.ZERO
		play_walk_animation(Vector2.ZERO)

		return


	# Get next point on navigation path
	var next_position := navigation_agent.get_next_path_position()

	var direction := global_position.direction_to(next_position)


	# Move toward player
	velocity = direction * chase_speed

	move_and_slide()


	# Animation
	play_walk_animation(direction)


# ========================================
# WANDER
# ========================================

func wander(delta: float) -> void:

	wander_timer -= delta


	# Time to choose a new destination
	if wander_timer <= 0.0:

		pick_new_wander_target()

		return


	# Reached destination
	if navigation_agent.is_navigation_finished():

		pick_new_wander_target()

		return


	# Get next path position
	var next_position := navigation_agent.get_next_path_position()

	var direction := global_position.direction_to(next_position)


	# If direction is invalid
	if direction.length() < 0.1:

		pick_new_wander_target()

		return


	# Move
	velocity = direction * wander_speed

	move_and_slide()


	# Animation
	play_walk_animation(direction)


# ========================================
# PICK RANDOM WANDER TARGET
# ========================================

func pick_new_wander_target() -> void:

	# Random amount of time before choosing again
	wander_timer = randf_range(
		wander_min_time,
		wander_max_time
	)


	# Make sure navigation map exists
	if navigation_map.is_valid() == false:

		return


	var random_point := Vector2.ZERO

	var found_point := false


	# Try up to 20 times
	for i in range(20):

		random_point = NavigationServer2D.map_get_random_point(
			navigation_map,
			1,
			true
		)


		# Make sure destination is at least
		# 100 pixels away
		if global_position.distance_to(random_point) >= minimum_wander_distance:

			found_point = true

			break


	# If we found a good point
	if found_point:

		navigation_agent.target_position = random_point

	else:

		# Try again later
		wander_timer = 0.5


	stuck_timer = 0.0


# ========================================
# CHECK IF MONSTER IS STUCK
# ========================================

func check_if_stuck(delta: float) -> void:

	var movement := global_position.distance_to(last_position)


	# Monster barely moved
	if movement < 1.0:

		stuck_timer += delta

	else:

		stuck_timer = 0.0


	# Monster has been stuck too long
	if stuck_timer >= stuck_time:

		stuck_timer = 0.0

		velocity = Vector2.ZERO


		# Pick a completely new destination
		if not chasing:

			pick_new_wander_target()

		else:

			# Recalculate chase path
			navigation_agent.target_position = player.global_position


	# Remember position
	last_position = global_position


# ========================================
# JUMPSCARE
# ========================================

func trigger_jumpscare() -> void:

	# Stop monster
	velocity = Vector2.ZERO

	# Stop movement
	set_physics_process(false)

	# Play jumpscare
	if jumpscare:

		jumpscare.play_jumpscare()


# ========================================
# ANIMATIONS
# ========================================

func play_walk_animation(direction: Vector2) -> void:

	# Standing still
	if direction == Vector2.ZERO:

		animated_sprite.play("f_idle")

		return


	# LEFT / RIGHT
	if abs(direction.x) > abs(direction.y):

		animated_sprite.play("s_walk")

		animated_sprite.flip_h = direction.x < 0


	# UP
	elif direction.y < 0:

		animated_sprite.play("b_walk")

		animated_sprite.flip_h = false


	# DOWN
	else:

		animated_sprite.play("f_walk")

		animated_sprite.flip_h = false
