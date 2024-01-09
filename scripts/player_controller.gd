extends Node2D

@onready var grid = $"../BattleLogic/Grid"
@onready var event_bus = $"../EventBus"

@onready var wind_slash = preload('res://scripts/wind_slash.gd')

enum PlayerState {
	SELECTING_TROOP, 
	SELECTING_MOVEMENT,
	SELECTING_ACTION, 
	SELECTING_SKILL,
	SELECTING_TARGET, 
	MOVING,
	IDLE,
  WAITING
}

@onready var units = $"../Units".get_children()

var player_state = PlayerState.WAITING
var current_unit: BaseUnit = null
var current_position := Vector2i.ZERO
var current_skill

var target_position := Vector2i.ZERO
var moved_units := 0
var unit_amount: int
var waiting = false

var RANGE = 4

var draw_pos = []
var square_color: Color
var square_texture = preload("res://graphics/UI/grid/pos_indicator.png")
const MOVEMENT_INDICATOR = preload("res://scenes/movement_indicator.tscn")

func _ready():
	unit_amount = 4

func _process(_delta):
	if not waiting:
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
		PlayerState.MOVING:
			player_moving()
		PlayerState.IDLE:
			await current_unit.unit_ended_turn
			player_state = PlayerState.SELECTING_TROOP
			
			if moved_units == unit_amount:
				await get_tree().create_timer(0.5).timeout
				event_bus.actor_ended_turn.emit()
				player_state = PlayerState.WAITING
				moved_units = 0
		PlayerState.WAITING:
			await event_bus.player_turn_started
			player_state = PlayerState.SELECTING_TROOP
			


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
	waiting = true
	var selected_action = await event_bus.action_selected
	waiting = false
	
	grid.undraw_positions()
	
	if selected_action[0] == "base_attack":
		player_state = PlayerState.SELECTING_TARGET
		var positions = selected_action[1]
		grid.draw_positions(positions, Color(1, 0, 0, 1))
		current_skill = current_unit.basic_attack
		
		waiting = true
		await get_tree().create_timer(0.05).timeout
		waiting = false
	
	if selected_action[0] == "wait":
		player_state = PlayerState.MOVING
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
			current_skill.skill_handler(target_position)
			
			player_state = PlayerState.MOVING
			grid.undraw_positions()

func player_moving():
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

func toggle_hp_bars():
	for unit: BaseUnit in units:
		unit.health_bar.visible = !unit.health_bar.visible
