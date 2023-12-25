extends Node2D

@onready var attack = $VBoxContainer/Attack
@onready var move = $VBoxContainer/Move
@onready var grid = $"../../BattleLogic/Grid"
@onready var player_unit = $"../../Units/PlayerUnit"
@onready var event_bus = $"../../EventBus"

func set_menu_position(selected_pos):
	var menu_pos = selected_pos - Vector2i(2,1) 
	menu_pos = grid.cell_to_global_position(menu_pos)
	global_position = menu_pos

func set_buttons_visibility(selected_pos):
	visible = true
	attack.visible = true
	
	var attack_range: Array[Vector2i] = player_unit.basic_attack_range(selected_pos)
	var enemies_in_range: Array[EnemyUnit] = grid.enemies_in_range(attack_range)
	
	if enemies_in_range.is_empty():
		attack.visible = false

func _on_event_bus_player_moved(target_pos):
	set_menu_position(target_pos)
	set_buttons_visibility(target_pos)
	await event_bus.action_selected
	visible = false

func _on_attack_pressed():
	event_bus.action_selected.emit("base_attack")

func _on_wait_pressed():
	event_bus.action_selected.emit("wait")
