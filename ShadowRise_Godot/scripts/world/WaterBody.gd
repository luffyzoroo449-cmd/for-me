## WaterBody.gd
## Provides buoyancy physics and visual splash effects when entering/exiting.
##
## Node Hierarchy:
## Area2D (WaterBody)
## ├── CollisionShape2D
## ├── Sprite2D (Water surface texture with shader)
## └── Marker2D (Surface level)

extends Area2D

@export var density: float = 1.2
@export var drag: float = 0.95

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	# Apply buoyancy to all overlapping bodies
	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			_apply_buoyancy(body)

func _apply_buoyancy(body: CharacterBody2D) -> void:
	# Calculate how deep the body is below the water surface
	var surface_y = global_position.y # Assuming center for simplicity, or use a Marker2D
	var depth = clamp(body.global_position.y - surface_y, 0, 50)
	
	if depth > 0:
		# Upward force based on depth
		var force = Vector2(0, -980 * density * (depth / 50.0))
		body.velocity += force * get_physics_process_delta_time()
		# Water resistance (drag)
		body.velocity *= drag

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		_spawn_splash(body.global_position)
		# Slow down dramatically on impact
		body.velocity.y *= 0.3

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		_spawn_splash(body.global_position)

func _spawn_splash(pos: Vector2) -> void:
	get_tree().call_group("game_world", "spawn_particles", {
		"position": pos,
		"color": Color("#60a5fa"), # Blue splash
		"count": 12,
		"type": "splash"
	})
