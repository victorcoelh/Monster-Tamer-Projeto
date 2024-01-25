extends TextureProgressBar

@onready var event_bus = $"../../../EventBus"
@onready var unit: BaseUnit = $".."

const DRAINING_MULTIPLY := 1000

func _ready():
	event_bus.unit_took_damage.connect(_on_event_bus_unit_took_damage)
	set_health_values()

func set_health_values():
	min_value = 0
	max_value = unit.max_hp * DRAINING_MULTIPLY
	value = unit.hp * DRAINING_MULTIPLY

func get_hp_draining_duration(damage: int) -> float:
	return 0.1 * damage if 0.1 * damage < 1.5 else 1.5

func _on_event_bus_unit_took_damage(target_unit: BaseUnit, damage: int):
	var target_bar = target_unit.health_bar
	var draining_duration: float = get_hp_draining_duration(damage)
	var tween = create_tween()
	
	tween.tween_property(target_bar, "value" , target_unit.hp * DRAINING_MULTIPLY, draining_duration)
	tween.tween_callback(tween.kill)
