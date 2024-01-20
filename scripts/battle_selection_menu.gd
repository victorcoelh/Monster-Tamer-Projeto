extends Node2D

@onready var attack = $HBoxContainer/VBoxContainer/Attack
@onready var skills = $HBoxContainer/VBoxContainer/Skills
@onready var move = $HBoxContainer/VBoxContainer/Move
@onready var grid = $"../../BattleLogic/Grid"
@onready var player_unit = $"../../Units/PlayerUnit"
@onready var event_bus = $"../../EventBus"
@onready var battle_camera = $"../../BattleCamera"
@onready var skills_container = $HBoxContainer/SkillsContainer

var font = load("res://fonts/m5x7.ttf")

var attack_range: Array[Vector2i]

func _ready():
	scale = scale / battle_camera.zoom
	
func set_menu_position(selected_pos):
	var menu_pos = selected_pos - Vector2i(2,1) 
	menu_pos = grid.cell_to_global_position(menu_pos)
	global_position = menu_pos
	
func set_buttons_visibility(selected_pos):
	attack_range = player_unit.basic_attack.skill_range(selected_pos)
	var enemies_in_range: Array[EnemyUnit] = grid.enemies_in_range(attack_range)
	
	if not enemies_in_range.is_empty():
		attack.visible = true
	visible = true

func _on_event_bus_player_moved(target_pos):
	set_menu_position(target_pos)
	set_buttons_visibility(target_pos)
	var selected_option = await event_bus.action_selected
	
	if selected_option[0] != "skills":
		visible = false
		attack.visible = false
		skills_container.visible = false

func _on_attack_pressed():
	event_bus.action_selected.emit("base_attack", attack_range)

func _on_wait_pressed():
	event_bus.action_selected.emit("wait", [])

func _on_skills_pressed():
	skills_container.visible = true
	event_bus.action_selected.emit("skills", [])


func _on_event_bus_unit_selecting_skills(unit: BaseUnit):
	for skill in unit.skills:
		create_skill_button(skill)

func create_skill_button(skill: Skill):
	var button: Button = Button.new()
	button.text = skill.skill_name
	button["theme_override_fonts/font"] = font
	button["theme_override_font_sizes/font_size"] = 48
	var event = func _on_pressed(): event_bus.skill_selected.emit(skill)
	button.pressed.connect(event)
	skills_container.add_child(button)




func _on_event_bus_skill_selected(skill):
	visible = false
	attack.visible = false
	skills_container.visible = false
	
	var skills = skills_container.get_children()
	
	for s in skills:
		skills_container.remove_child(s)
		s.queue_free()
