class_name BaseUnit
extends Node2D


@export var max_hp := 10
var hp := 10
var attack := 2
var current_path = []

@onready var grid = $"../Grid"


func _ready():
	pass


func _process(_delta):
	if current_path.is_empty():
		return
	
	var target_position = grid.cell_to_global_position(current_path.front())
	global_position = global_position.move_toward(target_position, 2)
	
	if global_position == target_position:
		current_path.pop_front()
		print(current_path)

func follow_path(path):
	current_path = path

#region Attack
func attack_action():
	var enemy_position: Vector2 = grid.selected_cell_position()
	var entity_position: Vector2 = grid.get_local_position(global_position)
	var enemy = grid.grid[enemy_position.x][enemy_position.y]
	
	if can_attack(entity_position, enemy_position):
		print("Attack!")
		
		enemy.hp -= attack
		print(str(enemy.hp) + "/" + str(enemy.max_hp))
		
		return
		
	print("You can't attack")

func can_attack(entity_pos: Vector2, enemy_position: Vector2) -> bool:
	var enemy = grid.grid[enemy_position.x][enemy_position.y]
	
	if enemy is Node2D and enemy.is_in_group("Unit"):
		return entity_pos.distance_to(enemy_position) == 1
		
	return false
#endregion
	
