## MovingPlatform.gd
## Attach to: AnimatableBody2D (Godot 4 name for Sync-to-Physics bodies)
## Supports: horizontal/vertical movement and physics-safe transport

extends AnimatableBody2D

@export var move_axis: String = "x" # "x" or "y"
@export var move_range: float = 100.0
@export var speed: float = 2.0

var start_pos: Vector2
var time: float = 0.0

func _ready() -> void:
	start_pos = global_position

func _physics_process(delta: float) -> void:
	time += delta * speed
	var offset = sin(time) * move_range
	
	if move_axis == "x":
		global_position.x = start_pos.x + offset
	else:
		global_position.y = start_pos.y + offset
