class_name Skill

var unit: BaseUnit
var skill_name: String

func _init(unit: BaseUnit):
	pass

func use_skill(atacker:BaseUnit, target: BaseUnit):
	push_error("use_skill is a abstract method, subclasses must override")

func skill_range(current_pos: Vector2i) -> Array[Vector2i]:
	push_error("skill_range is a abstract method, subclasses must override")
	return []

func skill_handler(desired_pos: Vector2i):
	push_error("skill_handler is a abstract method, subclasses must override")
