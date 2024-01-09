extends Skill

func _init(unit: BaseUnit):
	self.skill_name = "Wind slash"
	self.unit = unit

func use_skill(atacker:BaseUnit, target: BaseUnit):
	target.hp -= floor(0.75 * atacker.attack)
	print(str(target.hp) + "/" + str(target.max_hp))
	return atacker.attack

func skill_range(current_pos: Vector2i) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	
	for i in range(-3,4):
		if i == 0: continue
		positions.append(Vector2i(current_pos.x, current_pos.y + i))
		positions.append(Vector2i(current_pos.x + i, current_pos.y))
		
	return positions

func skill_handler(desired_pos: Vector2i):
	var selected_position = self.unit.grid.get_cell_at_mouse_position()
	var unit_position = self.unit.grid.global_to_cell_position(self.unit.global_position)
	
	if selected_position not in self.unit.grid.draw_pos:
		print("Out of range")
		return
	
	var targets: Array[EnemyUnit] = get_direction_targets(selected_position,desired_pos)
	
	if targets.is_empty():
		return
		
	for target:EnemyUnit in targets:
		self.unit.event_bus.unit_attacked.emit(self.unit, target, use_skill)
	
func get_direction_targets(selected_position: Vector2i, desired_pos: Vector2i) -> Array[EnemyUnit]:
	var WEST = selected_position.x < desired_pos.x
	if WEST:
		return get_targets(func (pos): return pos.x < desired_pos.x, desired_pos)
		
	var EAST = selected_position.x > desired_pos.x
	if EAST:
		return get_targets(func (pos): return pos.x > desired_pos.x, desired_pos)
	
	var NORTH = selected_position.y < desired_pos.y
	if NORTH:
		return get_targets(func (pos): return pos.y < desired_pos.y, desired_pos)
	
	return get_targets(func (pos): return pos.y > desired_pos.y, desired_pos)
	

func get_targets(filter_callback: Callable, desired_pos: Vector2i) -> Array[EnemyUnit]:
	var targets_pos = skill_range(desired_pos).filter(filter_callback)
	var targets: Array[EnemyUnit] = []
	
	for pos in targets_pos:
		var target = self.unit.grid.get_at(pos)
		
		if target is EnemyUnit:
			targets.append(target as EnemyUnit)
	
	print(targets)
	return targets
		


