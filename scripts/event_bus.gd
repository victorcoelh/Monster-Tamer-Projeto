extends Node2D

signal player_turn_started()
signal player_moved(target_pos: Vector2i)
signal action_selected(action: String)
signal unit_attacked(attacker: BaseUnit, target: BaseUnit, attack: Callable)
signal unit_took_damage(target_unit: BaseUnit, damage: int)
signal unit_ended_turn()
