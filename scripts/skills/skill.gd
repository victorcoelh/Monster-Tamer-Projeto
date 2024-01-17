class_name Skill

var unit: BaseUnit
var skill_name: String

enum SkillDirection {
	NORTH,
	SOUTH,
	WEST,
	EAST
}

func _init(_unit: BaseUnit):
	pass

func use_skill(_attacker:BaseUnit, _target: BaseUnit):
	push_error("use_skill is a abstract method, subclasses must override")

func skill_range(_current_pos: Vector2i) -> Array[Vector2i]:
	push_error("skill_range is a abstract method, subclasses must override")
	return []

func skill_handler(_desired_pos: Vector2i):
	push_error("skill_handler is a abstract method, subclasses must override")

func skill_direction(attacker_pos: Vector2i, selected_pos: Vector2i):
	var WEST = attacker_pos.x > selected_pos.x
	if WEST:
		return SkillDirection.WEST
		
	var EAST = attacker_pos.x < selected_pos.x
	if EAST:
		return SkillDirection.EAST
	
	var NORTH = attacker_pos.y > selected_pos.y
	if NORTH:
		return SkillDirection.NORTH
	
	return SkillDirection.SOUTH

func resolve_damage(attacker: BaseUnit, target: BaseUnit, modifier: float):
	var base_dmg = attacker.get_weapon_damage() * modifier
	var real_dmg = base_dmg - target.defense
	
	@warning_ignore("narrowing_conversion")
	target.hp -= real_dmg as int
	return real_dmg
