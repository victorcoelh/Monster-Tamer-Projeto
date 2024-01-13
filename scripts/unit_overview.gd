extends CanvasLayer

@onready var unit_name_label = $UnitName/UnitName
@onready var unit_movement_label = $UnitMovement/UnitMovement
@onready var unit_attack_label = $UnitAttack/UnitAttack
@onready var unit_speed_label = $UnitSpeed/UnitSpeed
@onready var unit_defense_label = $UnitDefense/UnitDefense
@onready var unit_hp_label = $UnitHP/UnitHP
@onready var health_bar = $HealthBar

@onready var player_controller = $"../../PlayerController"

var player_state
var PlayerState
var current_unit: BaseUnit

func _process(_delta):
	# TO-DO: Instead of checking the visibility and params in process, use signals
	player_state = player_controller.player_state
	PlayerState = player_controller.PlayerState
	current_unit = player_controller.current_unit

	if current_unit == null:
		visible = false
		return
		
	if player_state not in [PlayerState.IDLE, PlayerState.SELECTING_TROOP]:
		set_label_text()
		set_health_bar_value()
		visible = true
		return
	
	visible = false

func set_label_text():
	unit_name_label.text = current_unit.unit_name
	unit_movement_label.text = str(current_unit.movement)
	unit_speed_label.text = str(current_unit.speed)
	unit_attack_label.text = str(current_unit.attack)
	unit_defense_label.text = str(current_unit.defense)
	unit_hp_label.text = str(current_unit.hp) + "/" + str(current_unit.max_hp)

func set_health_bar_value():
	health_bar.min_value = 0
	health_bar.max_value = current_unit.max_hp
	health_bar.value = current_unit.hp
