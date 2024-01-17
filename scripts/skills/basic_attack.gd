extends Skill
class_name BasicAttack

func _init(parent_unit: BaseUnit):
	self.skill_name = "Attack"
	self.unit = parent_unit

func use_skill(attacker:BaseUnit, target: BaseUnit):
	var dmg = resolve_damage(attacker, target, 1)
	print(str(target.hp) + "/" + str(target.max_hp))
	return dmg

func skill_range(current_pos: Vector2i) -> Array[Vector2i]:
	var positions: Array[Vector2i] = [
		Vector2i(current_pos.x - 1, current_pos.y),
		Vector2i(current_pos.x + 1, current_pos.y),
		Vector2i(current_pos.x, current_pos.y + 1),
		Vector2i(current_pos.x, current_pos.y - 1),
	]
	return positions

func skill_handler(_desired_pos: Vector2i):
	var selected_position = self.unit.grid.get_cell_at_mouse_position()
	var selected_unit = self.unit.grid.get_at(selected_position)
	
	if selected_position not in self.unit.grid.draw_pos:
		print("Out of range")
		return
	
	if selected_unit is BaseUnit:
		self.unit.event_bus.unit_attacked.emit(self.unit, selected_unit, use_skill)
