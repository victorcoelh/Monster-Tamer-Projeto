extends Label

@onready var player_controller = $"../PlayerController"

func _process(_delta):
	var variables = [player_controller.PlayerState.keys()[player_controller.player_state], 
	player_controller.current_position, player_controller.target_position,
	player_controller.current_unit]
	
	text = "DEBUG:\n"
	
	for variable in variables:
		text = text + "\n" + str(variable)
