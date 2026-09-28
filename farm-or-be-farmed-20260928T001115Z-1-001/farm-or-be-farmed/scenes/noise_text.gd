extends Label

@export var player_path: NodePath

@onready var player = get_node(player_path)

func _process(_delta: float) -> void:
	if player:
		text = "Noise: " + str(round(player.current_noise))
