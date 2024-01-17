extends Node2D

# Battle flow
signal player_turn_started()
signal enemy_turn_started()
signal actor_ended_turn()

# Player actions
signal player_moved(target_pos: Vector2i)
signal unit_moved()
signal action_selected(action: String, range: Array[Vector2i])
signal unit_selecting_skills(unit: BaseUnit)
signal skill_selected(skill: Skill)

# Unit battling
signal unit_attacked(attacker: BaseUnit, target: BaseUnit, attack: Callable)
signal unit_took_damage(target_unit: BaseUnit, damage: int)
signal unit_ended_turn()
