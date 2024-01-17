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
var rng = RandomNumberGenerator.new()
var waiting_turn_end = true

signal open_battle_menu(selected_pos: Vector2i)
signal select_attack_target

const TURN_INDICATOR = preload("res://scenes/user_interface/turn_indicator.tscn")

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
		event_bus.player_turn_started.emit()
		_show_turn_indicator("PLAYER")
	elif current_actor == Actor.ENEMY:
		event_bus.enemy_turn_started.emit()
		_show_turn_indicator("ENEMY")
	
	turn_queue.append(current_actor)
	waiting_turn_end = true

func _show_turn_indicator(actor: String):
	var turn_indicator = TURN_INDICATOR.instantiate()
	turn_indicator.set_actor("PLAYER")
	add_child(turn_indicator)

func resolve_attack(attack: Callable, target_unit: BaseUnit, attacker: BaseUnit):
	var hit_chance: float = attacker.get_hit_rate() - target_unit.get_avoid_rate()
	var crit_chance: float = attacker.get_crit_rate()
	
	if (rng.randf() < hit_chance):
		var damage: int = attack.call(attacker, target_unit)
		damage *=- _get_damage_modifier(crit_chance, attacker)
		event_bus.unit_took_damage.emit(target_unit, damage)
	else:
		print("Attack Dodged!")
	
	await get_tree().create_timer(0.1).timeout
	event_bus.unit_ended_turn.emit()

func _get_damage_modifier(crit_chance: float, attacker: BaseUnit):
	if (rng.randf() < crit_chance):
		print("Critical Hit!")
		return attacker.CRIT_MODIFIER
	else:
		return 1

func unit_has_range(unit_pos: Vector2i, target_pos: Vector2i):
	var attack_range: Array[Vector2i] = current_unit.basic_attack_range(unit_pos)
	return target_pos in attack_range

func _on_event_bus_unit_attacked(attacker: BaseUnit, target: BaseUnit, attack: Callable):
	resolve_attack(attack, target, attacker)

func _on_event_bus_actor_ended_turn():
	waiting_turn_end = false
