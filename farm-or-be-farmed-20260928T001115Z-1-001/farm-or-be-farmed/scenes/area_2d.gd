extends Area2D

@export_multiline var note_text := "IT CAN HEAR YOU.

i was trapped down here for years and i think that it is blind, just whatever you do DONT MAKE A SOUND.

from your uncle randy.

(hold shift to walk quietly)"

var player_inside := false
var note_ui
var note_label


func _ready():
	# Find the note UI using its group
	var ui_nodes = get_tree().get_nodes_in_group("note_ui")

	if ui_nodes.is_empty():
		print("ERROR: No NoteUI found in the note_ui group!")
		return

	note_ui = ui_nodes[0]

	# Find the text using its group
	var text_nodes = get_tree().get_nodes_in_group("note_text")

	if text_nodes.is_empty():
		print("ERROR: No text node found in the note_text group!")
		return

	note_label = text_nodes[0]

	note_ui.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true
		open_note()


func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false


func open_note():
	note_label.text = note_text
	note_ui.visible = true

	get_tree().paused = true


func _process(_delta):
	if note_ui != null and note_ui.visible:
		if Input.is_action_just_pressed("ui_cancel"):
			close_note()


func close_note():
	note_ui.visible = false
	get_tree().paused = false
