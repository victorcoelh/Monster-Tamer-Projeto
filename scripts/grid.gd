extends Node2D

@export var size := Vector2(20, 20)
@export var cell_size := Vector2(32, 32)
@onready var astar_grid: AStarGrid2D

var grid = []
var initial_position = null
var final_position = null
var selected_unit
var path: Array[Vector2i]
var moving = false

@onready var player = $"../PlayerUnit"
@onready var enemy = $"../EnemyUnit"
@onready var base_tile_map = $"../BaseTileMap"

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_grid()
	setup_astar()
	
	var objects: Array[Vector2i] = base_tile_map.get_obstacles()
	add_objects_to_grid(objects, false)
	add_to_grid(player, Vector2(2,2))
	add_to_grid(enemy, Vector2(2,3))

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

func add_to_grid(object, relative_pos: Vector2):
	grid[relative_pos.x][relative_pos.y] = object

	var object_new_position: Vector2 = cell_to_global_position(relative_pos)
	object.global_position = object_new_position

func add_objects_to_grid(objects, passable):
	for object: Vector2 in objects:
		var new_object := GridObject.new(passable)
		grid[object.x][object.y] = new_object
		astar_grid.set_point_solid(object)
#endregion

#region Movement and Pathfinding
func get_movement_path(initial_pos, final_pos):
	path = astar_grid.get_id_path(initial_pos, final_pos)
	return path

func grid_move(initial_pos, final_pos):
	grid[final_pos.x][final_pos.y] = grid[initial_pos.x][initial_pos.y]
	grid[initial_pos.x][initial_pos.y] = null

func setup_astar():
	astar_grid = AStarGrid2D.new()
	var astar_size := cell_size * size
	
	astar_grid.region = Rect2(0,0,astar_size.x,astar_size.y)
	astar_grid.cell_size = cell_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
#endregion

#region Helpers
func cell_to_global_position(relative_position: Vector2):
	var x = relative_position.x * cell_size.x + cell_size.x/2
	var y = relative_position.y * cell_size.y + cell_size.y/2
	return Vector2(x, y)

func global_to_cell_position(original_position: Vector2):
	var x = floor(original_position.x / cell_size.x)
	var y = floor(original_position.y / cell_size.y)
	return Vector2(x,y)
#endregion

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

func draw_point(x: float, y: float, color) -> void:
	draw_rect(Rect2(x-4,y-4,8,8), color)
#endregion
