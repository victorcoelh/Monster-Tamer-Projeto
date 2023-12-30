extends Camera2D


@export var min_mouse_distance: int = 50
@export var max_speed: float = 4
@export var acceleration: float = 0.2
@export var lower_bounds: Vector2 = Vector2i(-3, -3)
@export var upper_bounds: Vector2 = Vector2i(25, 20)
@onready var grid = $"../BattleLogic/Grid"

var camera_size: Vector2i
var direction = Vector2.ZERO
var speed: float = 0
var elapsed_time = 0


func _ready():
	camera_size = get_viewport().size / 2
	lower_bounds *= grid.cell_size
	upper_bounds *= grid.cell_size

func _process(delta):
	if is_mouse_close_to_border():
		move_camera(delta)
	else:
		speed = 0
		elapsed_time = 0

func is_mouse_close_to_border():
	var mouse_pos = get_global_mouse_position()
	var diff: Vector2i = mouse_pos - global_position
	
	if diff.x < min_mouse_distance:
		direction = Vector2.LEFT
		return true
	elif camera_size.x - diff.x < min_mouse_distance:
		direction = Vector2.RIGHT
		return true
	elif diff.y < min_mouse_distance:
		direction = Vector2.UP
		return true
	elif camera_size.y - diff.y < min_mouse_distance:
		direction = Vector2.DOWN
		return true
	else:
		return false

func move_camera(delta):
	var new_position: Vector2
	
	elapsed_time += delta * acceleration
	speed = lerp(speed, max_speed, elapsed_time)
	new_position = global_position + speed*direction
	
	global_position.x = clamp(new_position.x, lower_bounds.x, upper_bounds.x - camera_size.x)
	global_position.y = clamp(new_position.y, lower_bounds.y, upper_bounds.y - camera_size.y)
