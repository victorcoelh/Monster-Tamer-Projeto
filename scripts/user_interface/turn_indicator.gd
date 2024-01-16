extends CanvasLayer


@onready var label = $MarginContainer/Control/Label
var label_text = ""

func _ready():
	label.text = label_text

func set_actor(actor: String):
	label_text = actor + " TURN"
