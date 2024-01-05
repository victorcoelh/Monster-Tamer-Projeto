extends Node2D


enum ArrowType {
	END,
	STRAIGHT,
	CORNER
}

@onready var sprite_2d = $Sprite2D
var arrow_type: ArrowType = ArrowType.STRAIGHT
var rotation_radians := PI/2

func _ready():
	sprite_2d.set_frame(arrow_type)
	rotate(rotation_radians)

func set_indicator_rotation(diff: Vector2, diff_last := Vector2.ZERO):
	if diff_last != Vector2.ZERO:
		if (diff_last.y < 0 and diff.x > 0) or (diff_last.x < 0 and diff.y > 0):
			rotation_radians = 3*PI/2
		elif (diff_last.x > 0 and diff.y > 0) or (diff_last.y < 0 and diff.x < 0):
			rotation_radians = 0
		elif (diff_last.y > 0 and diff.x > 0) or (diff_last.x < 0 and diff.y < 0):
			rotation_radians = PI
		else:
			rotation_radians = PI/2
	else:
		rotation_radians = diff.y * PI/2
		rotation_radians += diff.x * PI if diff.x < 0 else 0

func set_indicator_type(selected_arrow_type: ArrowType):
	arrow_type = selected_arrow_type
