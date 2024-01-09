class_name BaseUnit
extends Node2D
## Class to implement basic unit behavior, which should be shared between all
## units, including all player, enemy and ally units.
##
## Custom behavior should be implemented in the inheriting classes.

@export var max_hp := 10

var unit_name := "Endrick"

var hp := 10
var attack := 8
var speed := 5
var movement := 5
var armor := 7

var basic_attack = BasicAttack.new(self)
var skills: Array[Skill] = []

var current_path := []

@onready var grid = $"../../BattleLogic/Grid"
@onready var event_bus = $"../../EventBus"
@onready var health_bar = $HealthBar


func _process(_delta):
	if current_path.is_empty():
		return
		
	var target_position = grid.cell_to_global_position(current_path.front())
	global_position = global_position.move_toward(target_position, 2)
	
	if global_position == target_position:
		current_path.pop_front()
	
	if current_path.is_empty():
		event_bus.unit_moved.emit()
		event_bus.unit_ended_turn.emit()

#func basic_attack(enemy: BaseUnit):
	#enemy.hp -= attack
	#print(str(enemy.hp) + "/" + str(enemy.max_hp))
	#return attack
#
#func basic_attack_range(current_pos: Vector2i) -> Array[Vector2i]:
	#var positions: Array[Vector2i] = [
		#Vector2i(current_pos.x - 1, current_pos.y),
		#Vector2i(current_pos.x + 1, current_pos.y),
		#Vector2i(current_pos.x, current_pos.y + 1),
		#Vector2i(current_pos.x, current_pos.y - 1),
	#]
	#return positions
#
#func basic_attack_handler():
	#var selected_position = grid.get_cell_at_mouse_position()
	#var selected_unit = grid.get_at(selected_position)
	#
	#if selected_position not in grid.draw_pos:
		#print("Out of range")
		#return
	#
	#if selected_unit is BaseUnit:
		#event_bus.unit_attacked.emit(self, selected_unit, basic_attack)


func follow_path(path: Array[Vector2i]):
	current_path = path
	

