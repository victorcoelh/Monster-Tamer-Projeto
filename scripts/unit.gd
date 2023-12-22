class_name BaseUnit
extends Node2D


@export var max_hp := 10
var hp := 10
var attack := 2
var current_path = []

@onready var grid = $"../Grid"


func _process(_delta):
	if current_path.is_empty():
		return
	
	var target_position = grid.cell_to_global_position(current_path.front())
	global_position = global_position.move_toward(target_position, 2)
	
	if global_position == target_position:
		current_path.pop_front()
		print(current_path)

func basic_attack(enemy: BaseUnit):
	enemy.hp -= attack
	print(str(enemy.hp) + "/" + str(enemy.max_hp))
	
	return

func follow_path(path):
	current_path = path
