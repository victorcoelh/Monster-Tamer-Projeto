extends Skill

const WIND_SLASH_ANIM = preload("res://scenes/skills/wind_slash_anim.tscn")



func _init(parent_unit: BaseUnit):
	self.skill_name = "Wind slash"
	self.unit = parent_unit

func use_skill(attacker:BaseUnit, target: BaseUnit):
	var dmg = resolve_damage(attacker, target, 1)
	print(str(target.hp) + "/" + str(target.max_hp))
	return dmg

func skill_range(current_pos: Vector2i) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	
	for i in range(-3,4):
		if i == 0: continue
		positions.append(Vector2i(current_pos.x, current_pos.y + i))
		positions.append(Vector2i(current_pos.x + i, current_pos.y))
		
	return positions

func skill_handler(desired_pos: Vector2i):
	var selected_position = self.unit.grid.get_cell_at_mouse_position()
	
	if selected_position not in self.unit.grid.draw_pos:
		print("Out of range")
		return
	
	var targets: Array[EnemyUnit] = get_direction_targets(selected_position,desired_pos)

	if targets.is_empty():
		return
		
	self.create_animation(desired_pos, selected_position)
		
	for target:EnemyUnit in targets:
		self.unit.event_bus.unit_attacked.emit(self.unit, target, use_skill)

func get_direction_targets(selected_position: Vector2i, desired_pos: Vector2i) -> Array[EnemyUnit]:
	
	var direction: SkillDirection = self.skill_direction(desired_pos, selected_position)
	
	match direction:
		SkillDirection.WEST:
			return get_targets(func (pos): return pos.x < desired_pos.x, desired_pos)
		SkillDirection.EAST:
			return get_targets(func (pos): return pos.x > desired_pos.x, desired_pos)
		SkillDirection.NORTH:
			return get_targets(func (pos): return pos.y < desired_pos.y, desired_pos)
		SkillDirection.SOUTH:
			return get_targets(func (pos): return pos.y > desired_pos.y, desired_pos)
	
	return []

func get_targets(filter_callback: Callable, desired_pos: Vector2i) -> Array[EnemyUnit]:
	var targets_pos = skill_range(desired_pos).filter(filter_callback)
	var targets: Array[EnemyUnit] = []
	
	for pos in targets_pos:
		var target = self.unit.grid.get_at(pos)
		
		if target is EnemyUnit:
			targets.append(target as EnemyUnit)
	
	print(targets)
	return targets

func create_animation(attacker_pos: Vector2i, target_pos: Vector2i):
	var direction: SkillDirection = self.skill_direction(attacker_pos, target_pos)
	
	var sprite_rotation: int
	
	match direction:
		SkillDirection.WEST: sprite_rotation = 0
		SkillDirection.EAST: sprite_rotation = -180
		SkillDirection.NORTH: sprite_rotation = 90
		SkillDirection.SOUTH: sprite_rotation = -90
			
	
	var skill_animation = WIND_SLASH_ANIM.instantiate()
	skill_animation.rotation_degrees = sprite_rotation
	
	
	self.unit.add_child(skill_animation)
	
