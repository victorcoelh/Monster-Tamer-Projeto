extends CanvasLayer


@onready var grid = $"../../BattleLogic/Grid"
@onready var terrain_label = $Container/TerrainLabel
@onready var effect_label = $Container/EffectLabel

var terrain_type


func _process(delta):
	terrain_type = get_terrain_at_mouse_position()
	set_parameters_for_terrain(terrain_type)

func get_terrain_at_mouse_position():
	var mouse_pos = grid.get_cell_at_mouse_position()
	return grid.terrain_manager.get_at(mouse_pos)

func set_parameters_for_terrain(terrain):
	match terrain:
		grid.collision_tile_map.TileLayer.FOREST:
			terrain_label.text = "Forest"
			effect_label.text = "+10% AVO"
		_: # default case
			terrain_label.text = "Plains"
			effect_label.text = "-"
