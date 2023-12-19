extends Node2D


@export var size := Vector2(20, 20)
@export var cell_size := Vector2(32, 32)

var grid = []
var initial_position = null

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_grid()
	

func _process(_delta):
	check_mouse()
	queue_redraw()
	

func _draw():
	for i in range(grid.size()):
		for j in range(grid[i].size()):
			var global_pos = get_cell_position(Vector2(i, j))
			var selected_pos = get_cell_position(selected_cell())
			
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
		if initial_position == null:
			initial_position = selected_cell()
		else:
			move(initial_position, selected_cell())
			initial_position = null
		print(initial_position)


func add_to_grid(object, relative_pos: Vector2):
	grid[relative_pos.x][relative_pos.y] = object


func get_cell_position(relative_position: Vector2):
	var x = relative_position.x * cell_size.x + cell_size.x/2
	var y = relative_position.y * cell_size.y + cell_size.y/2
	return Vector2(x, y)
	

func move(initial_pos: Vector2, final_pos: Vector2):
	grid[final_pos.x][final_pos.y] = grid[initial_pos.x][initial_pos.y]
	grid[initial_pos.x][initial_pos.y] = null


func selected_cell() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	var selected_pos = floor(mouse_pos / cell_size)
	return selected_pos


func draw_point(x: float, y: float, color) -> void:
	draw_rect(Rect2(x-4,y-4,8,8), color)
