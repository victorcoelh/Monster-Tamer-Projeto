extends TileMap


enum TileLayer {GROUND, OBSTACLES}

# Called when the node enters the scene tree for the first time.
func _ready():
	get_obstacles()


func get_obstacles() -> Array[Vector2i]:
	return get_used_cells(TileLayer.OBSTACLES)
