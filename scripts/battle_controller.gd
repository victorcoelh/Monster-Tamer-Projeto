extends Node2D
## Node to control all battle-related behavior, such as attacking and
## turn selection. Actual processing should be done outside of this node.

@onready var grid = $"../Grid"

var current_unit: BaseUnit = null
var current_position := Vector2.ZERO
var turn_queue := []

var unit_is_acting = false
var desired_pos: Vector2i

signal open_battle_menu(selected_pos: Vector2i)
signal select_attack_target

@onready var battle_selection_menu = $"../../BattleSelectionMenu"


func _process(_delta):
	check_mouse()

#region Check mouse
func check_mouse():
	if Input.is_action_just_released("Select") and battle_selection_menu.is_selecting_target:
		select_attack_target.emit()
		
		var target_pos = await battle_selection_menu.attack_target_selected	
		
		
		if unit_has_range(desired_pos, target_pos):
			resolve_attack(current_unit.basic_attack, target_pos)
			move_unit(current_position, desired_pos)	
		
			await current_unit.finished_moving

		
		
		
		
	if Input.is_action_just_released("Select") and !unit_is_acting:
		if current_unit == null:
			get_unit_at_mouse_position()
			return
		
		if !battle_selection_menu.visible:
			var selected_pos = grid.get_cell_at_mouse_position()
			open_battle_menu.emit(selected_pos)
			
			var selected_option = await battle_selection_menu.button_pressed

			if selected_option == "base_attack":
				base_attack_selected(selected_pos)
			if selected_option == "move":
				move_selected(selected_pos)
				
		
	#if Input.is_action_just_released("Attack"):
		#if current_unit != null:
			#print("Attack!")
			#var target_position = get_unit_at_mouse_position()
			#resolve_attack(current_unit.basic_attack, target_position)

func move_selected(selected_position: Vector2i):
	unit_is_acting = true
	move_unit(current_position, selected_position)

func move_unit(current_pos:Vector2i, selected_pos: Vector2i):
	var path = grid.get_movement_path(current_pos, selected_pos)
	grid.grid_move(current_pos, selected_pos)
	current_unit.follow_path(path)
	
func base_attack_selected(selected_pos):
	unit_is_acting = true
	battle_selection_menu.is_selecting_target = true
	desired_pos = selected_pos
#endregion

func get_unit_at_mouse_position() -> Vector2i:
	var selected_position = grid.get_cell_at_mouse_position()
	var selected_unit = grid.get_at(selected_position)
	
	if selected_unit is BaseUnit and current_unit == null:
		print("Selected Unit")
		current_position = selected_position
		current_unit = selected_unit
	
	return selected_position

func resolve_attack(attack: Callable, target_position: Vector2i):
	## Functinal based approach, which applies an attack function
	## over one or more targets.
	
	var target_unit = grid.get_at(target_position)
	
	if target_unit is BaseUnit:
		attack.call(target_unit)

func unit_has_range(unit_pos, target_pos: Vector2i):
	var attack_range: Array[Vector2i] = current_unit.basic_attack_range(unit_pos)
	return target_pos in attack_range

func _on_player_unit_finished_moving():
	unit_is_acting = false
	current_unit = null
	
