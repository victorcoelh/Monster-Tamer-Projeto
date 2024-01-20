extends Node2D

const COMBAT_DISPLAY = preload("res://scenes/combat_display.tscn")
@onready var user_interface = $"../UserInterface"
@onready var units = $"../Units"

# Called when the node enters the scene tree for the first time.
func _ready():
	for unit in units.get_children():
		var display = COMBAT_DISPLAY.instantiate()
		user_interface.add_child(display)
		display.set_display(unit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
