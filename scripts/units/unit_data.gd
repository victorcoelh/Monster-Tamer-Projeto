class_name UnitData

var max_hp: int
var max_sp: int
var attack: int
var defense: int
var perception: int
var speed: int
var movement: int

var skills: Array[Object]
var unit_name: String

@warning_ignore("shadowed_variable")
func _init(unit_name: String, max_hp: int, max_sp: int, attack: int, defense: int,
		   perception: int, speed: int, movement: int, skills: Array[Object]):
	self.unit_name = unit_name
	self.max_hp = max_hp
	self.max_sp = max_sp
	self.attack = attack
	self.defense = defense
	self.perception = perception
	self.speed = speed
	self.movement = movement
	self.skills = skills
