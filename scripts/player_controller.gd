extends Node2D

@onready var grid = $"../BattleLogic/Grid"
@onready var event_bus = $"../EventBus"

enum PlayerState {
	SELECTING_TROOP,
	SELECTING_MOVEMENT,
	SELECTING_ACTION,
	SELECTING_TARGET,
	MOVING,
	IDLE
}

@onready var units = $"../Units".get_children()

var player_state = PlayerState.IDLE
var current_unit: BaseUnit = null
var current_position := Vector2i.ZERO
var target_position := Vector2i.ZERO
var waiting = false

var RANGE = 4
var draw_pos = []
var square_color: Color
var texture = preload("res://graphics/UI/pos_indicator.png")


func _ready():
	pass

func _process(_delta):
	handle_player_input()

#region Player Turn Control
func handle_player_input():
	if Input.is_action_just_released("Toggle Health Bar"):
		toggle_hp_bars()
	
	match player_state:
		PlayerState.SELECTING_TROOP:
			player_selecting_troop()
		PlayerState.SELECTING_MOVEMENT:
			player_selecting_movement()
		PlayerState.SELECTING_ACTION:
			await player_selecting_action()
		PlayerState.SELECTING_TARGET:
			player_selecting_target()
		PlayerState.MOVING:
			player_moving()
		PlayerState.IDLE:
			await event_bus.player_turn_started
			player_state = PlayerState.SELECTING_TROOP

func player_selecting_troop():
	if Input.is_action_just_released("Select"):
		get_unit_at_mouse_position()
		var positions = grid.tiles_in_counted_range(current_position, 4)
		draw_positions(positions)
		player_state = PlayerState.SELECTING_MOVEMENT

func player_selecting_movement():
	if Input.is_action_just_released("Select"):
		target_position = grid.get_cell_at_mouse_position()
		
		if target_position not in draw_pos:
			print("Out of range")
			return
	
		event_bus.player_moved.emit(target_position)
		player_state = PlayerState.SELECTING_ACTION

func player_selecting_action():
	var selected_action = await event_bus.action_selected
	undraw_positions()
	
	if selected_action[0] == "base_attack":
		player_state = PlayerState.SELECTING_TARGET
		var positions = selected_action[1]
		draw_positions(positions, Color(1, 0, 0, 1))
		
		waiting = true
		await get_tree().create_timer(0.05).timeout
		waiting = false
	
	if selected_action[0] == "wait":
		player_state = PlayerState.MOVING

func player_selecting_target():
	if Input.is_action_just_released("Select") and not waiting:
		var selected_position = grid.get_cell_at_mouse_position()
		var selected_unit = grid.get_at(selected_position)
		
		if selected_position not in draw_pos:
			print("Out of range")
			return
		
		if selected_unit is BaseUnit:
			event_bus.unit_attacked.emit(current_unit, selected_unit, current_unit.basic_attack)
			player_state = PlayerState.MOVING
			undraw_positions()

func player_moving():
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
#endregion

#region Movement Drawing
func draw_positions(positions: Array[Vector2i], color := Color(1, 1, 1, 1)):
	draw_pos = positions
	square_color = color
	queue_redraw()

func undraw_positions():
	draw_pos = []
	queue_redraw()

func _draw():
	for pos in draw_pos:
		var global_pos = grid.cell_to_global_position(pos)
		draw_texture(texture, global_pos - Vector2(16, 16), square_color)
#endregion

func toggle_hp_bars():
	for unit: BaseUnit in units:
		unit.health_bar.visible = !unit.health_bar.visible
