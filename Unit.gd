extends Node2D


var hp := 10
@export var max_hp := 10
var attack := 2

@onready var grid_node = $"../Grid"

func _ready():
	pass



func _process(delta):
	pass


#region Attack
func attack_action():
	var enemy_position: Vector2 = grid_node.selected_cell_position()
	var entity_position: Vector2 = grid_node.get_local_position(global_position)
	var enemy = grid_node.grid[enemy_position.x][enemy_position.y]
	
	if can_attack(entity_position, enemy_position):
		print("Attack!")
		
		enemy.hp -= attack
		print(str(enemy.hp) + "/" + str(enemy.max_hp))
		
		return
		
	print("You can't attack")
	

func can_attack(entity_pos: Vector2, enemy_position: Vector2) -> bool:
	var enemy = grid_node.grid[enemy_position.x][enemy_position.y]
	
	if enemy != null and enemy.is_in_group("Unit"):
		return entity_pos.distance_to(enemy_position) == 1
		
	return false
#endregion
	
