extends Node2D

@onready var grid = $"../../BattleLogic/Grid"
@onready var event_bus = $"../../EventBus"

enum PlayerState {
	SELECTING_TROOP,
	SELECTING_MOVEMENT,
	SELECTING_ACTION,
	SELECTING_TARGET,
	MOVING,
	IDLE
}

var player_state = PlayerState.IDLE
var current_unit: BaseUnit = null
var current_position := Vector2i.ZERO
var target_position := Vector2i.ZERO


func _ready():
	pass

func _process(_delta):
	check_mouse()

func check_mouse():
	match player_state:
		PlayerState.SELECTING_TROOP:
			check_mouse_selecting_troop()
		PlayerState.SELECTING_MOVEMENT:
			check_mouse_selecting_movement()
		PlayerState.SELECTING_ACTION:
			await check_mouse_selecting_action()
		PlayerState.SELECTING_TARGET:
			check_mouse_sleecting_target()
		PlayerState.MOVING:
			check_mouse_moving()
		PlayerState.IDLE:
			await event_bus.player_turn_started
			player_state = PlayerState.SELECTING_TROOP

func check_mouse_selecting_troop():
	if Input.is_action_just_released("Select"):
		get_unit_at_mouse_position()
		player_state = PlayerState.SELECTING_MOVEMENT

func check_mouse_selecting_movement():
	if Input.is_action_just_released("Select"):
		target_position = grid.get_cell_at_mouse_position()
		event_bus.player_moved.emit(target_position)
		player_state = PlayerState.SELECTING_ACTION

func check_mouse_selecting_action():
	var selected_action = await event_bus.action_selected
	
	if selected_action == "base_attack":
		player_state = PlayerState.SELECTING_TARGET
	if selected_action == "wait":
		player_state = PlayerState.MOVING

func check_mouse_sleecting_target():
	if Input.is_action_just_released("Select"):
		var selected_position = grid.get_cell_at_mouse_position()
		var selected_unit = grid.get_at(selected_position)
		
		if selected_unit is BaseUnit:
			event_bus.unit_attacked.emit(current_unit, selected_unit, current_unit.basic_attack)
			player_state = PlayerState.MOVING

func check_mouse_moving():
	var path = grid.get_movement_path(current_position, target_position)
	grid.grid_move(current_position, target_position)
	current_unit.follow_path(path)
	player_state = PlayerState.IDLE

func get_unit_at_mouse_position() -> Vector2i:
	var selected_position = grid.get_cell_at_mouse_position()
	var selected_unit = grid.get_at(selected_position)
	
	if selected_unit is BaseUnit:
		print("Selected Unit")
		current_position = selected_position
		current_unit = selected_unit
	
	return selected_position
