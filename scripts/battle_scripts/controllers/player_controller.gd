extends Node2D


enum PlayerState {
	SELECTING_TROOP,
	SELECTING_MOVEMENT,
	SELECTING_ACTION,
	SELECTING_SKILL,
	SELECTING_TARGET,
	IDLE,
	WAITING
}

var player_state = PlayerState.WAITING
var current_unit: BaseUnit = null
var current_position := Vector2i.ZERO
var current_skill: Skill
var target_position := Vector2i.ZERO
var moved_units := 0
var unit_amount: int
var waiting := false

@onready var units = $"../Units".get_children()
@onready var grid = $"../BattleLogic/Grid"
@onready var event_bus = $"../EventBus"

const MOVEMENT_INDICATOR = preload("res://scenes/user_interface/movement_indicator.tscn")

func _ready():
	unit_amount = units.size()

func _process(_delta):
	if not waiting and is_mouse_within_grid():
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
		PlayerState.SELECTING_SKILL:
			await player_selecting_skill()
		PlayerState.SELECTING_TARGET:
			player_selecting_target()
		PlayerState.IDLE:
			player_idle()
		PlayerState.WAITING:
			player_waiting()

func player_selecting_troop():
	if Input.is_action_just_released("Select"):
		if get_unit_at_mouse_position():
			var positions = grid.tiles_in_counted_range(current_position, 4)
			grid.draw_positions(positions)
			player_state = PlayerState.SELECTING_MOVEMENT

func player_selecting_movement():
	var mouse_path = grid.get_movement_path(current_position, grid.get_cell_at_mouse_position())
	undraw_movement_indicators()
	draw_movement_indicators(mouse_path)
	
	if Input.is_action_just_released("Select"):
		target_position = grid.get_cell_at_mouse_position()
		if target_position not in grid.draw_pos:
			print("Out of range")
			return
		
		event_bus.player_moved.emit(target_position)
		player_state = PlayerState.SELECTING_ACTION

func player_selecting_action():
	# TODO: reuse some of the skills' code for base_attack
	waiting = true
	var selected_action = await event_bus.action_selected
	waiting = false
	
	grid.undraw_positions()
	move_player()
	
	if selected_action[0] == "base_attack":
		player_state = PlayerState.SELECTING_TARGET
		var positions = selected_action[1]
		grid.draw_positions(positions, Color(1, 0, 0, 1))
		current_skill = current_unit.basic_attack
		
		waiting = true
		await get_tree().create_timer(0.05).timeout
		waiting = false
	
	if selected_action[0] == "skills":
		event_bus.unit_selecting_skills.emit(current_unit)
		player_state = PlayerState.SELECTING_SKILL
	
func player_selecting_skill():
	var skill: Skill = await event_bus.skill_selected
	current_skill = skill
	
	var positions = skill.skill_range(target_position)
	grid.draw_positions(positions, Color(1, 0, 0, 1))
	player_state = PlayerState.SELECTING_TARGET
	
	waiting = true
	await get_tree().create_timer(0.20).timeout
	waiting = false

func player_selecting_target():
	if Input.is_action_just_released("Select") and not waiting:
		player_state = PlayerState.IDLE
		current_skill.skill_handler(target_position)
		grid.undraw_positions()

func player_idle():
	waiting = true
	await event_bus.unit_ended_turn
	waiting = false
	player_state = PlayerState.SELECTING_TROOP
	
	if moved_units == unit_amount:
		await get_tree().create_timer(0.5).timeout
		event_bus.actor_ended_turn.emit()
		player_state = PlayerState.WAITING
		moved_units = 0

func player_waiting():
	waiting = true
	await event_bus.player_turn_started
	waiting = false
	player_state = PlayerState.SELECTING_TROOP

func move_player():
	var path = grid.get_movement_path(current_position, target_position)
	grid.grid_move(current_position, target_position)
	current_unit.follow_path(path)
	
	player_state = PlayerState.IDLE
	moved_units += 1
	undraw_movement_indicators()

func get_unit_at_mouse_position() -> bool:
	var selected_position = grid.get_cell_at_mouse_position()
	var selected_unit = grid.get_at(selected_position)
	
	if selected_unit is BaseUnit and not selected_unit.inactive:
		current_position = selected_position
		current_unit = selected_unit
		return true
	return false
#endregion

#region Indicator Drawing
func draw_movement_indicators(positions: Array[Vector2i]):
	if false in positions.map(func(x): return x in grid.draw_pos):
		return
	
	for i in range(0, positions.size()):
		var global_pos = grid.cell_to_global_position(positions[i])
		var indicator := MOVEMENT_INDICATOR.instantiate()
		indicator.global_position = global_pos
		
		if i == positions.size()-1:
			indicator.set_indicator_rotation(positions[i] - positions[i-1])
			indicator.set_indicator_type(indicator.ArrowType.END)
		elif i == 0:
			indicator.set_indicator_rotation(positions[i+1] - positions[i])
			indicator.set_indicator_type(indicator.ArrowType.START)
		elif (positions[i+1] - positions[i-1]).length_squared() < 4:
			indicator.set_indicator_rotation(positions[i+1] - positions[i], positions[i] - positions[i-1])
			indicator.set_indicator_type(indicator.ArrowType.CORNER)
		else:
			indicator.set_indicator_rotation(positions[i+1] - positions[i])
			indicator.set_indicator_type(indicator.ArrowType.STRAIGHT)
		
		add_child(indicator)

func undraw_movement_indicators():
	for child in get_children():
		child.queue_free()
#endregion

func is_mouse_within_grid():
	var mouse_pos = get_global_mouse_position()
	var first_pos = grid.cell_to_global_position(Vector2(0, 0))
	var final_pos = grid.cell_to_global_position(grid.size)
	
	if mouse_pos.x < first_pos.x or mouse_pos.y < first_pos.y:
		return false
	elif mouse_pos.x > final_pos.x or mouse_pos.y > final_pos.y:
		return false
	else:
		return true

func toggle_hp_bars():
	for unit: BaseUnit in units:
		unit.health_bar.visible = !unit.health_bar.visible
