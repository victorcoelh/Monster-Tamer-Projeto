extends Node2D

@onready var grid = $"../Grid"

var current_unit: BaseUnit = null
var current_position := Vector2.ZERO

func _ready():
	pass

func _process(_delta):
	check_mouse()

func check_mouse():
	if Input.is_action_just_released("Select"):
		get_unit_at_mouse_position()
		
	if Input.is_action_just_released("Attack"):
		if current_unit != null:
			resolve_attack()

func get_unit_at_mouse_position():
	var selected_position = get_cell_at_mouse_position()
	var selected_unit = grid.grid[selected_position.x][selected_position.y]
	
	if selected_unit is BaseUnit and current_unit == null:
		print("Selected unit")
		current_position = selected_position
		current_unit = selected_unit
		return
	
	if current_unit != null:
		var path = grid.get_movement_path(current_position, selected_position)
		grid.grid_move(current_position, selected_position)
		current_unit.follow_path(path)
		current_unit = null

func resolve_attack():
	pass

func get_cell_at_mouse_position() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	var selected_pos = floor(mouse_pos / grid.cell_size)
	return selected_pos
