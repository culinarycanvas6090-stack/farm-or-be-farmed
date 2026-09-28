extends Area2D

@export var hits_needed: int = 10
@export_file("*.tscn") var main_menu_scene: String = "res://scenes/mainmenu.tscn"

var hits: int = 0
var player_near := false
var game_won := false

var win_label
var tree_counter
var tree_visual
var tree_collision


func _ready():
	# Find everything using groups
	var label_nodes = get_tree().get_nodes_in_group("win_label")
	var counter_nodes = get_tree().get_nodes_in_group("tree_counter")
	var visual_nodes = get_tree().get_nodes_in_group("tree_visual")
	var collision_nodes = get_tree().get_nodes_in_group("tree_collision")

	if label_nodes.is_empty():
		print("ERROR: No node in win_label group!")
		return

	if counter_nodes.is_empty():
		print("ERROR: No node in tree_counter group!")
		return

	if visual_nodes.is_empty():
		print("ERROR: No node in tree_visual group!")
		return

	if collision_nodes.is_empty():
		print("ERROR: No node in tree_collision group!")
		return

	win_label = label_nodes[0]
	tree_counter = counter_nodes[0]
	tree_visual = visual_nodes[0]
	tree_collision = collision_nodes[0]

	# Hide win message
	win_label.visible = false

	# Set starting counter
	tree_counter.text = "Chops: 0 / " + str(hits_needed)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	print("TREE READY")


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		print("PLAYER IS NEAR TREE")


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		print("PLAYER LEFT TREE")


func _process(_delta):
	if player_near and not game_won:
		if Input.is_action_just_pressed("interact"):
			print("E PRESSED - CHOPPING")
			chop_tree()


func chop_tree():
	hits += 1

	# Update counter
	tree_counter.text = "Chops: " + str(hits) + " / " + str(hits_needed)

	print("CHOP! ", hits, "/", hits_needed)

	if hits >= hits_needed:
		win_game()


func win_game():
	game_won = true

	print("TREE CHOPPED!")
	print("YOU WIN!")

	# Hide tree
	tree_visual.visible = false

	# Disable collision
	tree_collision.set_deferred("disabled", true)

	# Show win message
	win_label.text = "YOU WIN!\n\nAnd you farmed happily ever after."
	win_label.visible = true

	# Wait 3 seconds
	await get_tree().create_timer(3.0).timeout

	# Go to main menu
	get_tree().change_scene_to_file(main_menu_scene)
