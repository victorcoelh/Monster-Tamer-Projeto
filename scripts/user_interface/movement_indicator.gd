extends Node2D


enum ArrowType {
	END,
	STRAIGHT,
	START,
	CORNER
}

@onready var sprite_2d = $Sprite2D
var arrow_type: ArrowType = ArrowType.STRAIGHT
var rotation_index := 0

func _ready():
	sprite_2d.set_frame(arrow_type)
	sprite_2d.frame_coords = Vector2(sprite_2d.frame_coords.x, rotation_index)

func set_indicator_rotation(diff: Vector2, diff_last := Vector2.ZERO):
	if diff_last != Vector2.ZERO:
		if (diff_last.y < 0 and diff.x > 0) or (diff_last.x < 0 and diff.y > 0):
			rotation_index = 2
		elif (diff_last.x > 0 and diff.y > 0) or (diff_last.y < 0 and diff.x < 0):
			rotation_index = 3
		elif (diff_last.y > 0 and diff.x > 0) or (diff_last.x < 0 and diff.y < 0):
			rotation_index = 0
		else:
			rotation_index = 1
	else:
		if diff.y == -1:
			rotation_index = 0
		elif diff.y == 1:
			rotation_index = 1
		elif diff.x == -1:
			rotation_index = 2
		else:
			rotation_index = 3

func set_indicator_type(selected_arrow_type: ArrowType):
	arrow_type = selected_arrow_type
