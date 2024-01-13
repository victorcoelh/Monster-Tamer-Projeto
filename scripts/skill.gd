class_name Skill

var unit: BaseUnit
var skill_name: String

func _init(unit: BaseUnit):
	pass

func use_skill(attacker:BaseUnit, target: BaseUnit):
	push_error("use_skill is a abstract method, subclasses must override")

func skill_range(current_pos: Vector2i) -> Array[Vector2i]:
	push_error("skill_range is a abstract method, subclasses must override")
	return []

func skill_handler(desired_pos: Vector2i):
	push_error("skill_handler is a abstract method, subclasses must override")

func resolve_damage(attacker: BaseUnit, target: BaseUnit, modifier: float):
	var base_dmg = attacker.get_weapon_damage() * modifier
	var real_dmg = base_dmg - target.defense
	
	target.hp -= real_dmg
	return real_dmg
