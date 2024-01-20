extends CanvasLayer
class_name CombatDisplay

@onready var top_big_box = $Control/BigBox/Top

@onready var dmg_top = $Control/AttributeBox/DMGBox/Top
@onready var hit_top = $Control/AttributeBox/HITBox/Top
@onready var crit_top = $Control/AttributeBox/CRITBox/Top

@onready var unit_name = $Control/BigBox/UnitName

@onready var dmg_count = $Control/DMGText/DMGCount
@onready var hit_count = $Control/HITText/HITCount
@onready var crit_count = $Control/CRITText/CRITCount

@onready var health_bar = $Control/BigBox/HealthBar

@onready var control = $Control

var color_scheme: Dictionary = {
	'ALLY': Color(0.392157, 0.584314, 0.929412, 1),
	'ENEMY': Color(0.933, 0.294, 0.169, 1)
}

func _ready():
	pass

func set_display(unit: BaseUnit):
	if unit is EnemyUnit:
		change_box_color(color_scheme['ENEMY'])
		control.anchor_left = 0.3
	if unit is PlayerUnit:

		change_box_color(color_scheme['ALLY'])
	
	set_attributes(unit)

func change_box_color(color: Color):
	top_big_box.self_modulate = color
	dmg_top.self_modulate = color
	hit_top.self_modulate = color
	crit_top.self_modulate = color

func set_attributes(unit: BaseUnit):
	unit_name.text = unit.unit_name
	dmg_count.text = str(unit.get_weapon_damage())
	hit_count.text = str(unit.get_hit_rate() * 100)
	crit_count.text = str(unit.get_crit_rate() * 100)
	
	health_bar.min_value = 0
	health_bar.max_value = unit.max_hp
	health_bar.value = unit.hp
	
	
