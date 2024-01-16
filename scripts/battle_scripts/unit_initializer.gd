extends Node

@onready var grid = $"../Grid"
@onready var units = $"../../Units"

# Mocks for testing, should be deleted later
var endrick_data: UnitData
var yuri_alberto_data: UnitData

var player_scene = preload("res://scenes/units/player_unit.tscn")
var enemy_scene = preload("res://scenes/units/enemy_unit.tscn")

var wind_slash = preload("res://scripts/skills/wind_slash.gd")
var whirlwind = preload("res://scripts/skills/whirlwind.gd")
var backstab = preload("res://scripts/skills/backstab.gd")

enum UnitType {
	PLAYER,
	ENEMY
}

func _ready():
	# Mock endrick
	endrick_data = UnitData.new("Endrick", 30, 20, 12, 7, 12, 14, 6, [])
	
	# Mock Y. Alberto
	yuri_alberto_data = UnitData.new("Yuri Alberto", 32, 27, 15, 10, 8, 9, 6,
									[wind_slash, whirlwind, backstab])
	
	instantiate_unit(yuri_alberto_data, UnitType.ENEMY, Vector2i(6,5))
	instantiate_unit(endrick_data,UnitType.ENEMY, Vector2i(5,5))
	instantiate_unit(yuri_alberto_data, UnitType.PLAYER, Vector2i(6,6))

func instantiate_unit(unit_params:UnitData, unit_type: UnitType, pos: Vector2i):
	var unit = get_unit_type(unit_type).instantiate()
	units.add_child(unit)
	move_unit_to_grid(unit, pos)
	set_unit_params(unit,unit_params)
	
func get_unit_type(type: UnitType):
	if type == UnitType.PLAYER:
		return player_scene
	
	return enemy_scene

func move_unit_to_grid(unit, pos:Vector2i):
	grid.add_to_grid(unit, pos)
	
	var unit_global_pos = grid.cell_to_global_position(pos)
	unit.global_position = unit_global_pos

func set_unit_params(unit:BaseUnit, params: UnitData):
	unit.unit_name = params.unit_name
	unit.max_hp = params.max_hp
	unit.hp = params.max_hp
	unit.max_sp = params.max_sp
	unit.sp = params.max_sp
	unit.attack = params.attack
	unit.defense = params.defense
	unit.perception = params.perception
	unit.speed = params.speed
	unit.movement = params.movement
	
	for skill: Object in params.skills:
		var new_skill: Skill = skill.new(unit)
		unit.skills.append(new_skill)
