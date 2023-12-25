extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	print("BORA BILL")

func kill_explosion():
	queue_free()
