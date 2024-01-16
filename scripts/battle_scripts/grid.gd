extends Node2D
## A class for creating and managing the combat system's grid layout.

@export var size := Vector2(20, 20)
@export var cell_size := Vector2(32, 32)
@onready var astar_grid: AStarGrid2D

var grid = []
var initial_position = null
var final_position = null
var selected_unit
var path: Array[Vector2i]
var moving = false
var draw_pos = []
var square_color: Color
var texture = preload("res://graphics/user_interface/grid/pos_indicator.png")
@onready var units = $"../../Units"
@onready var base_tile_map = $"../../BaseTileMap"


func _ready():
	initialize_grid()
	setup_astar()
	
	var objects: Array[Vector2i] = base_tile_map.get_obstacles()
	add_objects_to_grid(objects, false)
	
func _process(_delta):
	queue_redraw()

func _draw():
	draw_grid_lines()
	draw_debug_points()
	draw_move_squares()

#region Grid Control
func initialize_grid():
	for i in range(size.x):
		var row = []
		@warning_ignore("narrowing_conversion")
		row.resize(size.y)
		row.fill(null)
		grid.append(row)

func add_to_grid(object: Object, relative_pos: Vector2i):
	set_at(object, relative_pos)
	astar_grid.set_point_solid(relative_pos)

	var object_new_position: Vector2 = cell_to_global_position(relative_pos)
	object.global_position = object_new_position

func add_objects_to_grid(object_positions: Array[Vector2i], passable: bool):
	for object: Vector2 in object_positions:
		if object.x < 0 or object.y < 0 or object.x >= size.x or object.y >= size.y:
			continue
		var new_object := GridObject.new(passable)
		grid[object.x][object.y] = new_object
		astar_grid.set_point_solid(object)

func get_cell_at_mouse_position() -> Vector2i:
	var mouse_pos = get_global_mouse_position()
	var selected_pos = floor(mouse_pos / cell_size)
	return selected_pos

func get_at(vector_position: Vector2i) -> Object:
	return grid[vector_position.x][vector_position.y]
	
func set_at(obj: Object, pos: Vector2):
	grid[pos.x][pos.y] = obj
#endregion

#region Movement and Pathfinding
func get_movement_path(initial_pos: Vector2i, final_pos: Vector2i) -> Array[Vector2i]:
	path = astar_grid.get_id_path(initial_pos, final_pos)
	return path

func grid_move(initial_pos: Vector2i, final_pos: Vector2i):
	if initial_pos != final_pos:
		var unit = get_at(initial_pos)
		set_at(unit,final_pos)
		set_at(null, initial_pos)
		
		astar_grid.set_point_solid(final_pos, true)
		astar_grid.set_point_solid(initial_pos, false)

func setup_astar():
	astar_grid = AStarGrid2D.new()
	var astar_size := cell_size * size
	
	astar_grid.region = Rect2(0,0,astar_size.x,astar_size.y)
	astar_grid.cell_size = cell_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
func entities_in_range(positions:Array[Vector2i]) -> Array[BaseUnit]:
	var entities: Array[BaseUnit] = []
	
	for pos in positions:
		var entity = get_at(pos)
		if entity is BaseUnit:
			entities.append(entity)
	
	return entities

func enemies_in_range(positions: Array[Vector2i]) -> Array[EnemyUnit]:
	var entities: Array[BaseUnit] = entities_in_range(positions)
	var enemies: Array[EnemyUnit] = []
	
	for entity in entities:
		if entity is EnemyUnit:
			enemies.append(entity)
	
	return enemies

func tiles_in_counted_range(initial_pos: Vector2i, tile_range: int) -> Array[Vector2i]:
	## Implements the DFS Algorithm on the grid, returning all cells
	## within a given range of the initial cell.
	var frontier: Array[Vector2i] = [initial_pos]
	var output: Array[Vector2i] = [initial_pos]
	var distances = {initial_pos: 0}
	
	while not frontier.is_empty():
		var current = frontier.pop_front()
		var at_limit = distances[current] == tile_range
		var not_empty = get_at(current) != null
		var is_initial = current == initial_pos # initial_pos is a special case
		
		if at_limit or not_empty and not is_initial:
			continue
		
		for neighbor in get_neighbors(current):
			if neighbor not in distances:
				frontier.append(neighbor)
				output.append(neighbor)
				distances[neighbor] = distances[current] + 1
	return output

func get_neighbors(tile_position: Vector2i):
	return [tile_position + Vector2i(0, -1),
			tile_position + Vector2i(0, 1),
			tile_position + Vector2i(-1, 0),
			tile_position + Vector2i(1, 0)]
#endregion

#region Helpers
func cell_to_global_position(relative_position: Vector2i):
	var x = relative_position.x * cell_size.x + cell_size.x/2
	var y = relative_position.y * cell_size.y + cell_size.y/2
	return Vector2(x, y)

func global_to_cell_position(original_position: Vector2):
	var x = floor(original_position.x / cell_size.x)
	var y = floor(original_position.y / cell_size.y)
	return Vector2(x,y)
#endregion

#region Grid Drawing
func draw_grid_lines():
	for i in range(size.x+1):
		var starting_pos = cell_to_global_position(Vector2(i, 0))
		var end_pos = cell_to_global_position(Vector2(i, size.y))
		draw_grid_line(starting_pos, end_pos, Color(0, 0, 0, 0.1))
	for j in range(size.y+1):
		var starting_pos = cell_to_global_position(Vector2(0, j))
		var end_pos = cell_to_global_position(Vector2(size.x, j))
		draw_grid_line(starting_pos, end_pos, Color(0, 0, 0, 0.1))

func draw_grid_line(starting_pos: Vector2, end_pos: Vector2, color: Color):
	draw_line(starting_pos - cell_size/2, end_pos - cell_size/2, color, 2.0)

func draw_debug_points():
	for i in range(size.x):
		for j in range(size.y):
			var global_pos = cell_to_global_position(Vector2(i, j))
			
			if grid[i][j] is GridObject:
				draw_point(global_pos.x, global_pos.y, Color.YELLOW)
				continue

func draw_point(x: float, y: float, color):
	draw_rect(Rect2(x-4,y-4,8,8), color)
#endregion

#region Movement Drawing
func draw_positions(positions: Array[Vector2i], color := Color(1, 1, 1, 1)):
	draw_pos = positions
	square_color = color
	queue_redraw()

func undraw_positions():
	draw_pos = []
	queue_redraw()

func draw_move_squares():
		for pos in draw_pos:
			var global_pos = cell_to_global_position(pos)
			draw_texture(texture, global_pos - Vector2(16, 16), square_color)
#endregion

## Class used to serve as a representation of possible obstacles on the grid,
## such as a tree, a hill, or a wall. Additional variables may be added
## to represent additional behavior.
class GridObject:
	var passable: bool
	
	func _init(is_passable):
		self.passable = is_passable
