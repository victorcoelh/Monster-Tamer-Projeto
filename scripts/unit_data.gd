class_name UnitData

var max_hp: int
var attack: int
var armor: int
var speed: int
var movement: int

var skills: Array[Object]
var unit_name: String

func _init(unit_name:String, max_hp: int, attack: int, armor: int, speed: int, movement: int, skills: Array[Object]):
	self.unit_name = unit_name
	self.max_hp = max_hp
	self.attack = attack
	self.armor = armor
	self.speed = speed
	self.movement = movement
	self.skills = skills	

