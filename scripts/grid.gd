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

@onready var player = $"../Player"
@onready var enemy = $"../Enemy"
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
	check_mouse()
	queue_redraw()
	
	if path.is_empty():
		return
		
	var target_position = get_cell_position(path.front())
	player.global_position = player.global_position.move_toward(target_position, 2)
	
	if player.global_position == target_position:
		path.pop_front()
		print(path)
	
func _draw():
	for i in range(grid.size()):
		for j in range(grid[i].size()):
			var global_pos = get_cell_position(Vector2(i, j))
			var selected_pos = get_cell_position(selected_cell_position())
			
			if grid[i][j] is GridObject:
				draw_point(global_pos.x, global_pos.y, Color.YELLOW)
				continue
			
			if global_pos == selected_pos:
				draw_point(global_pos.x, global_pos.y, Color.BLUE)
				continue
			draw_point(global_pos.x, global_pos.y, Color.RED)


func initialize_grid():
	for i in range(size.x):
		var row = []
		row.resize(size.y)
		row.fill(null)
		grid.append(row)


func check_mouse():
	if Input.is_action_just_released("Select"):
		select_unit()
		
	if Input.is_action_just_released("Attack"):
		player.attack_action()

func select_unit():
	if selected_cell() is GridObject:
		return
		
	if initial_position == null and selected_cell() != null:
		initial_position = selected_cell_position()
		selected_unit = selected_cell()
		return

	if selected_unit != null :
		var final_position = selected_cell_position()
		move(selected_unit, initial_position, final_position)
		initial_position = null
		selected_unit = null
		print("moved")
		
	if selected_unit == null:
		initial_position = null	

func add_to_grid(object, relative_pos: Vector2):
	grid[relative_pos.x][relative_pos.y] = object
	
	var object_new_position: Vector2 = get_cell_position(relative_pos)
	object.global_position = object_new_position


func add_objects_to_grid(objects, passable):
	for object: Vector2 in objects:
		var new_object := GridObject.new(passable)
		grid[object.x][object.y] = new_object
		astar_grid.set_point_solid(object)
	

func get_cell_position(relative_position: Vector2):
	var x = relative_position.x * cell_size.x + cell_size.x/2
	var y = relative_position.y * cell_size.y + cell_size.y/2
	return Vector2(x, y)


func get_local_position(global_position: Vector2):
	var x = floor(global_position.x / cell_size.x)
	var y = floor(global_position.y / cell_size.y)
	return Vector2(x,y)


func move(object: Node2D, initial_pos: Vector2, final_pos: Vector2):
	if grid[final_pos.x][final_pos.y] is GridObject or final_pos == initial_pos:
		return
	
	path = astar_grid.get_id_path(initial_pos, final_pos)
	print(path)
	
	grid[final_pos.x][final_pos.y] = grid[initial_pos.x][initial_pos.y]
	grid[initial_pos.x][initial_pos.y] = null


func selected_cell_position() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	var selected_pos = floor(mouse_pos / cell_size)
	return selected_pos

func selected_cell() -> Object:
	var mouse_pos = get_global_mouse_position()
	var selected_pos = floor(mouse_pos / cell_size)
	return grid[selected_pos.x][selected_pos.y] 

func draw_point(x: float, y: float, color) -> void:
	draw_rect(Rect2(x-4,y-4,8,8), color)
	
func setup_astar():
	astar_grid = AStarGrid2D.new()
	var astar_size := cell_size * size
	
	astar_grid.region = Rect2(0,0,astar_size.x,astar_size.y)
	astar_grid.cell_size = cell_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()


class GridObject:
	var passable: bool
		
	func _init(passable):
		self.passable = passable
