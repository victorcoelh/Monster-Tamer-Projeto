extends Node2D


@onready var animation_player = $AnimationPlayer
var should_blink = true


func _ready():
	if should_blink:
		animation_player.play("default")
	else:
		animation_player.play("no blink")
