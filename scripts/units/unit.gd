class_name BaseUnit
extends Node2D
## Class to implement basic unit behavior, which should be shared between all
## units, including all player, enemy and ally units.
##
## Custom behavior should be implemented in the inheriting classes.

var current_path := []
var inactive = false

const UNIT_GRAYSCALE = preload("res://graphics/shaders/unit_grayscale.gdshader")
const BASE_CRIT = 0.05
const CRIT_MODIFIER = 2

@onready var grid = $"../../BattleLogic/Grid"
@onready var event_bus = $"../../EventBus"
@onready var health_bar = $HealthBar
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer


# unit parameters
@export var max_hp := 10
@export var max_sp := 10
var unit_name := "Endrick"
var hp := 10
var sp := 10
var attack := 8
var defense := 8
var perception := 6
var speed := 5
var movement := 5

# unit attacks
var basic_attack = BasicAttack.new(self)
var skills: Array[Skill] = []

# game parameters
const UNIT_MOVE_SPEED = 100

func _ready():
	event_bus.actor_ended_turn.connect(_on_event_bus_actor_turn_ended)

func _process(_delta):
	if current_path.is_empty():
		return
		
	var target_position = grid.cell_to_global_position(current_path.front())
	global_position = global_position.move_toward(target_position, _delta * UNIT_MOVE_SPEED)
	
	if global_position == target_position:
		current_path.pop_front()
	
	if current_path.is_empty():
		event_bus.unit_moved.emit()
		event_bus.unit_ended_turn.emit()
		turn_inactive()

func follow_path(path: Array[Vector2i]):
	current_path = path
	animation_player.play("walking")
	
	if current_path[-1].x < current_path[0].x: # going left
		sprite_2d.flip_h = true

#region Secondary Stats
func get_crit_rate() -> float:
	return BASE_CRIT + perception/100.0

func get_avoid_rate() -> float:
	var avoid_rate = speed/100.0 # DO NOT delete the .0, as Godot will turn this into an integer division
	var grid_pos = grid.global_to_cell_position(global_position)
	
	if grid.terrain_manager.get_at(grid_pos) == grid.collision_tile_map.TileLayer.FOREST:
		avoid_rate *= 1.1
	return avoid_rate 

func get_hit_rate() -> float:
	return 0.8 + perception/50.0

func get_weapon_damage() -> int:
	return attack
#endregion

#region Handling Troop Inactivity
func turn_inactive():
	var shader_material = ShaderMaterial.new()
	shader_material.shader = UNIT_GRAYSCALE
	sprite_2d.material = shader_material
	sprite_2d.flip_h = false
	
	inactive = true
	animation_player.play("idle")
	animation_player.stop()

func awake():
	sprite_2d.material = null
	inactive = false
	animation_player.play("idle")

func _on_event_bus_actor_turn_ended():
	awake()
#endregion
