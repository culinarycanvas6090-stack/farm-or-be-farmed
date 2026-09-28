extends Area2D

@export_multiline var riddle := "answer my riddle and you may pass. I speak without a mouth and hear without ears. I have no body, but I come alive with wind. What am I?"

@export var correct_answer := "echo"

@export_file("*.tscn") var next_scene := "res://scenes/basement.tscn"


var riddle_ui
var riddle_text
var answer_box
var result_text
var submit_button

var player_inside := false


func _ready():
	# Find Riddle UI
	var ui_nodes = get_tree().get_nodes_in_group("riddle_ui")

	if ui_nodes.is_empty():
		print("ERROR: No riddle_ui found!")
		return

	riddle_ui = ui_nodes[0]


	# Find riddle text
	var text_nodes = get_tree().get_nodes_in_group("riddle_text")

	if text_nodes.is_empty():
		print("ERROR: No riddle_text found!")
		return

	riddle_text = text_nodes[0]


	# Find answer box
	var answer_nodes = get_tree().get_nodes_in_group("riddle_answer")

	if answer_nodes.is_empty():
		print("ERROR: No riddle_answer found!")
		return

	answer_box = answer_nodes[0]


	# Find result text
	var result_nodes = get_tree().get_nodes_in_group("riddle_result")

	if result_nodes.is_empty():
		print("ERROR: No riddle_result found!")
		return

	result_text = result_nodes[0]


	# Find submit button
	var submit_nodes = get_tree().get_nodes_in_group("riddle_submit")

	if submit_nodes.is_empty():
		print("ERROR: No riddle_submit found!")
		return

	submit_button = submit_nodes[0]


	# Hide UI
	riddle_ui.visible = false


	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	answer_box.text_submitted.connect(_on_answer_submitted)
	submit_button.pressed.connect(_on_submit_pressed)


func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true
		open_riddle()


func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false


func open_riddle():
	riddle_text.text = riddle
	answer_box.text = ""
	result_text.text = ""

	answer_box.editable = true
	submit_button.disabled = false

	riddle_ui.visible = true

	answer_box.grab_focus()

	get_tree().paused = true


func _on_answer_submitted(answer):
	check_answer(answer)


func _on_submit_pressed():
	check_answer(answer_box.text)


func check_answer(answer):
	answer = answer.strip_edges().to_lower()

	# CORRECT ANSWER
	if answer == correct_answer.to_lower():

		result_text.text = "Good job!\nBack to the surface with you."

		answer_box.editable = false
		submit_button.disabled = true

		# Wait 3 seconds while the game is paused
		await get_tree().create_timer(3.0, true).timeout

		get_tree().paused = false
		get_tree().change_scene_to_file(next_scene)

	# WRONG ANSWER
	else:

		# Restart the current scene
		get_tree().paused = false
		get_tree().reload_current_scene()


func _process(_delta):
	if riddle_ui != null and riddle_ui.visible:

		if Input.is_action_just_pressed("ui_cancel"):
			close_riddle()


func close_riddle():
	riddle_ui.visible = false
	get_tree().paused = false
