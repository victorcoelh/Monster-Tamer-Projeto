extends Skill

const WHIRLWIND_ANIM = preload("res://scenes/skills/whirlwind_anim.tscn")

func _init(unit: BaseUnit):
	self.skill_name = "Whirlwind"
	self.unit = unit

func use_skill(attacker:BaseUnit, target: BaseUnit):
	var dmg = resolve_damage(attacker, target, 1)
	print(str(target.hp) + "/" + str(target.max_hp))
	return dmg

func skill_range(current_pos: Vector2i) -> Array[Vector2i]:
	var positions: Array[Vector2i] = [
		Vector2i(current_pos.x -1 , current_pos.y - 1),
		Vector2i(current_pos.x, current_pos.y - 1),
		Vector2i(current_pos.x + 1 , current_pos.y - 1),
		Vector2i(current_pos.x - 1 , current_pos.y),
		Vector2i(current_pos.x + 1 , current_pos.y),
		Vector2i(current_pos.x - 1 , current_pos.y + 1),
		Vector2i(current_pos.x , current_pos.y + 1),
		Vector2i(current_pos.x + 1 , current_pos.y + 1),
	]
	
	return positions

func skill_handler(desired_pos: Vector2i):
	self.create_animation()
	for pos: Vector2i in skill_range(desired_pos):
		if self.unit.grid.get_at(pos) is EnemyUnit:
			var target: EnemyUnit = self.unit.grid.get_at(pos)
			self.unit.event_bus.unit_attacked.emit(self.unit, target, use_skill)

func create_animation():
	var skill_animation = WHIRLWIND_ANIM.instantiate()
	self.unit.add_child(skill_animation)
