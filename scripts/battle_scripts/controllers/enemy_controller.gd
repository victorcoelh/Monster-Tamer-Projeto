extends Node2D


@onready var event_bus = $"../EventBus"


func _ready():
	pass

func _process(delta):
	pass


func _on_event_bus_enemy_turn_started():
	await get_tree().create_timer(3.0).timeout
	event_bus.actor_ended_turn.emit()
