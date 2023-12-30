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

@onready var units = $"../../Units"
@onready var base_tile_map = $"../../BaseTileMap"


func _ready():
	initialize_grid()
	setup_astar()
	
	var objects: Array[Vector2i] = base_tile_map.get_obstacles()
	add_objects_to_grid(objects, false)
	
	#var i = 0
	#for unit in units.get_children():
		#add_to_grid(unit, Vector2i(i, i))
		#i += 1
	var unites = units.get_children()
	add_to_grid(unites[0], Vector2i(5,5))
	add_to_grid(unites[1], Vector2i(6,6))

func _process(_delta):
	queue_redraw()

func _draw():
	draw_debug_points()

#region Grid Control
func initialize_grid():
	for i in range(size.x):
		var row = []
		@warning_ignore("narrowing_conversion")
		row.resize(size.y)
		row.fill(null)
		grid.append(row)

func add_to_grid(object: Object, relative_pos: Vector2i):
	grid[relative_pos.x][relative_pos.y] = object

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
#endregion

#region Movement and Pathfinding
func get_movement_path(initial_pos: Vector2i, final_pos: Vector2i) -> Array[Vector2i]:
	path = astar_grid.get_id_path(initial_pos, final_pos)
	return path

func grid_move(initial_pos: Vector2i, final_pos: Vector2i):
	if initial_pos != final_pos:
		grid[final_pos.x][final_pos.y] = grid[initial_pos.x][initial_pos.y]
		grid[initial_pos.x][initial_pos.y] = null

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
		var entity = grid[pos.x][pos.y]
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

func tiles_in_counted_range(initial_pos: Vector2i, tile_range: int):
	# TODO: Implement a better algorithm. The one I implemented here is shit.
	var possible_tiles: Array[Vector2i] = [initial_pos]
	var current_pos: Vector2i
	var diff: Vector2i
	var dfs_queue = []
	dfs_queue.append_array(get_neighbors(initial_pos))
	
	while not dfs_queue.is_empty():
		current_pos = dfs_queue.pop_front()
		diff = current_pos - initial_pos
		
		if current_pos.x >= size.x or current_pos.y >= size.y or current_pos.x < 0 or current_pos.y < 0:
			continue
		
		if abs(diff.x) + abs(diff.y) <= tile_range and current_pos not in possible_tiles and get_at(current_pos) == null:
			possible_tiles.append(current_pos)
			
			for neighbor in get_neighbors(current_pos):
				if neighbor not in dfs_queue:
					dfs_queue.append(neighbor)
	return possible_tiles

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

## Class used to serve as a representation of possible obstacles on the grid,
## such as a tree, a hill, or a wall. Additional variables may be added
## to represent additional behavior.
class GridObject:
	var passable: bool
	
	func _init(is_passable):
		self.passable = is_passable

#region Debug
func draw_debug_points():
	for i in range(grid.size()):
		for j in range(grid[i].size()):
			var global_pos = cell_to_global_position(Vector2(i, j))
			
			if grid[i][j] is GridObject:
				draw_point(global_pos.x, global_pos.y, Color.YELLOW)
				continue
			draw_point(global_pos.x, global_pos.y, Color.RED)

func draw_point(x: float, y: float, color):
	draw_rect(Rect2(x-4,y-4,8,8), color)
#endregion
