extends Node2D

@export var size := Vector2(20, 20)
@export var cell_size := Vector2(32, 32)

@onready var astar_grid: AStarGrid2D

@onready var label = $"../Label"


var grid = []
var initial_position = null
var final_position = null
var selected_unit
var path
var moving = false

@onready var player = $"../Player"
@onready var enemy = $"../Enemy"

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_grid()
	add_to_grid(player, Vector2(2,2))
	add_to_grid(enemy, Vector2(2,3))
	
func _process(_delta):
	check_mouse()
	queue_redraw()
	
	
	
func _draw():
	for i in range(grid.size()):
		for j in range(grid[i].size()):
			var global_pos = get_cell_position(Vector2(i, j))
			var selected_pos = get_cell_position(selected_cell_position())
			
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
	if initial_position == null:
		initial_position = selected_cell_position()
		selected_unit = selected_cell()
		return

	if selected_unit != null :
		var final_position = selected_cell_position()
		move(selected_unit, initial_position, final_position)
		initial_position = null
		selected_unit = null
				
	if selected_unit == null:
		initial_position = null	
		
func add_to_grid(object, relative_pos: Vector2):
	grid[relative_pos.x][relative_pos.y] = object
	
	var object_new_position: Vector2 = get_cell_position(relative_pos)
	object.global_position = object_new_position


func get_cell_position(relative_position: Vector2):
	var x = relative_position.x * cell_size.x + cell_size.x/2
	var y = relative_position.y * cell_size.y + cell_size.y/2
	return Vector2(x, y)

func get_local_position(global_position: Vector2):
	var x = floor(global_position.x / cell_size.x)
	var y = floor(global_position.y / cell_size.y)
	return Vector2(x,y)
	
func move(object: Node2D, initial_pos: Vector2, final_pos: Vector2):
	if final_pos != initial_pos:
		grid[final_pos.x][final_pos.y] = grid[initial_pos.x][initial_pos.y]
		grid[initial_pos.x][initial_pos.y] = null
	
		var object_new_position: Vector2 = get_cell_position(final_pos)
		object.global_position = object_new_position
	
func selected_cell_position() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	var selected_pos = floor(mouse_pos / cell_size)
	return selected_pos

func selected_cell() -> Node2D:
	var mouse_pos = get_global_mouse_position()
	var selected_pos = floor(mouse_pos / cell_size)
	return grid[selected_pos.x][selected_pos.y] 

func draw_point(x: float, y: float, color) -> void:
	draw_rect(Rect2(x-4,y-4,8,8), color)
