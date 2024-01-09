extends Node2D
## Node to control all battle-related behavior, such as attacking and
## turn selection. Actual processing should be done outside of this node.


enum Actor {
	PLAYER,
	ENEMY
}

var current_unit: BaseUnit = null
var current_position := Vector2.ZERO
var turn_queue: Array[Actor] = []
var explosion = preload("res://scenes/explosion.tscn")
const TURN_INDICATOR = preload("res://scenes/turn_indicator.tscn")
var waiting_turn_end = true

signal open_battle_menu(selected_pos: Vector2i)
signal select_attack_target

@onready var battle_selection_menu = $"../../UserInterface/BattleSelectionMenu"
@onready var event_bus = $"../../EventBus"
@onready var grid = $"../Grid"


func _ready():
	turn_queue.append(Actor.PLAYER)
	turn_queue.append(Actor.ENEMY)
	await get_tree().create_timer(1.0).timeout
	waiting_turn_end = false

func _process(_delta):
	if not waiting_turn_end:
		resolve_turn()

func resolve_turn():
	var current_actor: Actor = turn_queue.pop_front()
	
	if current_actor == Actor.PLAYER:
		print("Player Turn")
		event_bus.player_turn_started.emit()
		var turn_indicator = TURN_INDICATOR.instantiate()
		turn_indicator.set_actor("PLAYER")
		add_child(turn_indicator)
	elif current_actor == Actor.ENEMY:
		print("Enemy Turn")
		event_bus.enemy_turn_started.emit()
		var turn_indicator = TURN_INDICATOR.instantiate()
		turn_indicator.set_actor("ENEMY")
		add_child(turn_indicator)
	
	turn_queue.append(current_actor)
	waiting_turn_end = true

func resolve_attack(attack: Callable, target_unit: BaseUnit, attacker):
	## Functinal based approach, which applies an attack function
	## over one or more targets.
	var damage: int = attack.call(attacker, target_unit)
	event_bus.unit_took_damage.emit(target_unit, damage) 
	
	var instance = explosion.instantiate()
	target_unit.add_child(instance)

func unit_has_range(unit_pos: Vector2i, target_pos: Vector2i):
	var attack_range: Array[Vector2i] = current_unit.basic_attack_range(unit_pos)
	return target_pos in attack_range

func _on_event_bus_unit_attacked(attacker: BaseUnit, target: BaseUnit, attack: Callable):
	resolve_attack(attack, target, attacker)

func _on_event_bus_actor_ended_turn():
	waiting_turn_end = false

