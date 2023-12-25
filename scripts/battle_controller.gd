extends Node2D
## Node to control all battle-related behavior, such as attacking and
## turn selection. Actual processing should be done outside of this node.

var current_unit: BaseUnit = null
var current_position := Vector2.ZERO
var turn_queue := []
var explosion = preload("res://scenes/explosion.tscn")

signal open_battle_menu(selected_pos: Vector2i)
signal select_attack_target

@onready var battle_selection_menu = $"../../UserInterface/BattleSelectionMenu"
@onready var event_bus = $"../../EventBus"
@onready var grid = $"../Grid"

func _process(_delta):
	if Input.is_action_just_released("Cancel"):
		event_bus.player_turn_started.emit()

func resolve_attack(attack: Callable, target_unit: BaseUnit):
	## Functinal based approach, which applies an attack function
	## over one or more targets.
	attack.call(target_unit)
	var instance = explosion.instantiate()
	target_unit.add_child(instance)

func unit_has_range(unit_pos: Vector2i, target_pos: Vector2i):
	var attack_range: Array[Vector2i] = current_unit.basic_attack_range(unit_pos)
	return target_pos in attack_range

func _on_event_bus_unit_attacked(attacker: BaseUnit, target: BaseUnit, attack: Callable):
	resolve_attack(attack, target)
