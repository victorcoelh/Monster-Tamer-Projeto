extends TileMap

## All available layers in the TileMap being used.
enum TileLayer {GROUND, ROADS, OBSTACLES, TERRAINS}


func _ready():
	get_obstacles()
	
func get_obstacles() -> Array[Vector2i]:
	## Returns all Tiles in the Obstacles layer.
	return get_used_cells(TileLayer.OBSTACLES)
