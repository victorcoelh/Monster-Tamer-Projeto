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

func _ready():
	event_bus.unit_attacked.connect(_on_unit_attacked)

func _process(_delta):
	if Input.is_action_just_released("Cancel"):
		event_bus.player_turn_started.emit()

func resolve_attack(attack: Callable, target_position: Vector2i):
	## Functinal based approach, which applies an attack function
	## over one or more targets.
	
	var target_unit = grid.get_at(target_position)
	
	if target_unit is BaseUnit:
		attack.call(target_unit)
	
	print('borabill')
	var instance = explosion.instantiate()
	add_child(instance)

func unit_has_range(unit_pos, target_pos: Vector2i):
	var attack_range: Array[Vector2i] = current_unit.basic_attack_range(unit_pos)
	return target_pos in attack_range

func _on_unit_attacked(attacker: BaseUnit, target: BaseUnit, attack: Callable):
	attack.call(target)
	
	print('borabill')
	var instance = explosion.instantiate()
	target.add_child(instance)
