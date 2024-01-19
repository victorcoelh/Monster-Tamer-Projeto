extends Camera2D

@export var min_mouse_distance: int = 50
@export var max_speed: float = 3
@export var acceleration: float = 0.2
@export var lower_bounds: Vector2 = Vector2i(-3, -3)
@export var upper_bounds: Vector2 = Vector2i(25, 20)

var camera_size: Vector2i
var direction = Vector2.ZERO
var speed: float = 0
var elapsed_time: float = 0
var should_check_mouse := true
var slowing := false

@onready var grid = $"../BattleLogic/Grid"

func _ready():
	camera_size = get_viewport().size / 2
	lower_bounds *= grid.cell_size
	upper_bounds *= grid.cell_size

func _process(delta):
	if is_mouse_close_to_border() and should_check_mouse:
		speedup_camera(delta)
	else:
		slow_camera(delta)

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

func speedup_camera(delta):
	if slowing == true:
		elapsed_time = 0
		slowing = false
	
	var new_position: Vector2
	elapsed_time += delta * acceleration
	speed = lerp(speed, max_speed, elapsed_time)
	new_position = global_position + speed*direction
	move_camera(new_position)

func slow_camera(delta):
	if slowing == false:
		elapsed_time = 0
		slowing = true
	
	var new_position: Vector2
	elapsed_time += delta * acceleration
	speed = lerp(speed, 0.0, elapsed_time)
	new_position = global_position + speed*direction
	move_camera(new_position)

func move_camera(new_position: Vector2):
	global_position.x = clamp(new_position.x, lower_bounds.x, upper_bounds.x - camera_size.x)
	global_position.y = clamp(new_position.y, lower_bounds.y, upper_bounds.y - camera_size.y)

func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		should_check_mouse = true
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		should_check_mouse = false
