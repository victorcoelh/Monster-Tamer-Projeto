extends Skill 


const BACKSTAB_ANIM = preload("res://scenes/skills/backstab_anim.tscn")


func _init(parent_unit: BaseUnit):
	self.skill_name = "Backstab"
	self.unit = parent_unit

func use_skill(atacker:BaseUnit, target: BaseUnit):
	target.hp -= atacker.attack
	print(str(target.hp) + "/" + str(target.max_hp))
	return atacker.attack

func skill_range(current_pos: Vector2i) -> Array[Vector2i]:
	var positions: Array[Vector2i] = [
		Vector2i(current_pos.x - 1, current_pos.y),
		Vector2i(current_pos.x + 1, current_pos.y),
		Vector2i(current_pos.x, current_pos.y + 1),
		Vector2i(current_pos.x, current_pos.y - 1),
	]
	return positions

func skill_handler(desired_pos:Vector2i):
	var selected_position = self.unit.grid.get_cell_at_mouse_position()
	var selected_unit = self.unit.grid.get_at(selected_position)
	
	if selected_position not in self.unit.grid.draw_pos:
		print("Out of range")
		return
		
	if selected_unit is BaseUnit:	
		var back_pos: Vector2i = get_back_pos(selected_position, desired_pos)
		var blink: bool = false
		
		if self.unit.grid.get_at(back_pos) == null:
			var current_pos: Vector2i = self.unit.grid.global_to_cell_position(self.unit.global_position)
			self.unit.grid.grid_move(current_pos, back_pos)
			self.unit.global_position = self.unit.grid.cell_to_global_position(back_pos)
			blink = true
		
		self.create_animation(desired_pos, selected_position, blink)
		self.unit.event_bus.unit_attacked.emit(self.unit, selected_unit, use_skill)
 
func get_back_pos(selected_position: Vector2i, desired_pos:Vector2i) -> Vector2i:
	if selected_position.y > desired_pos.y:
		return selected_position + Vector2i(0,1)
	if selected_position.y < desired_pos.y:
		return selected_position + Vector2i(0,-1)
	if selected_position.x > desired_pos.x:
		return selected_position + Vector2i(1,0)
	if selected_position.x < desired_pos.x:
		return selected_position + Vector2i(-1, 0)
	
	return Vector2i(0,0)

func create_animation(attacker_pos: Vector2i, target_pos: Vector2i, blink: bool):
	var direction: SkillDirection = self.skill_direction(attacker_pos, target_pos)
	
	var sprite_rotation: int
	
	match direction:
		SkillDirection.WEST: sprite_rotation = -180
		SkillDirection.EAST: sprite_rotation = 0
		SkillDirection.NORTH: sprite_rotation = -90
		SkillDirection.SOUTH: sprite_rotation = 90
		
	var skill_animation = BACKSTAB_ANIM.instantiate()
	
	if !blink:
		skill_animation.should_blink = false
		sprite_rotation += 180
	
	skill_animation.rotation_degrees = sprite_rotation
	self.unit.add_child(skill_animation)
