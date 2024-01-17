extends TileMap

## All available layers in the TileMap being used.
enum TileLayer {UNPASSABLE, FOREST}

func get_tiles_at_layer(layer: TileLayer) -> Array[Vector2i]:
	## Returns all Tiles in the Obstacles layer.
	return get_used_cells(layer)
