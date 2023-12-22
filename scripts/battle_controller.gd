extends Node2D
## Node to control all battle-related behavior, such as attacking and
## turn selection. Actual processing should be done outside of this node.

@onready var grid = $"../Grid"

var current_unit: BaseUnit = null
var current_position := Vector2.ZERO
var turn_queue := []

func _process(_delta):
	check_mouse()

func check_mouse():
	if Input.is_action_just_released("Select"):
		if current_unit == null:
			get_unit_at_mouse_position()
			return
		else:
			var selected_position = get_unit_at_mouse_position()
			var path = grid.get_movement_path(current_position, selected_position)
			grid.grid_move(current_position, selected_position)
			current_unit.follow_path(path)
			current_unit = null
	
	if Input.is_action_just_released("Attack"):
		if current_unit != null:
			print("Attack!")
			var target_position = get_unit_at_mouse_position()
			resolve_attack(current_unit.basic_attack, target_position)

func get_unit_at_mouse_position() -> Vector2i:
	var selected_position = get_cell_at_mouse_position()
	var selected_unit = grid.grid[selected_position.x][selected_position.y]
	
	if selected_unit is BaseUnit and current_unit == null:
		print("Selected Unit")
		current_position = selected_position
		current_unit = selected_unit
	
	return selected_position

func resolve_attack(attack: Callable, target_position: Vector2i):
	## Functinal based approach, which applies an attack function
	## over one or more targets.
	var target_unit = grid.grid[target_position.x][target_position.y]
	
	if target_unit is BaseUnit:
		attack.call(target_unit)

func get_cell_at_mouse_position() -> Vector2i:
	var mouse_pos = get_global_mouse_position()
	var selected_pos = floor(mouse_pos / grid.cell_size)
	return selected_pos
