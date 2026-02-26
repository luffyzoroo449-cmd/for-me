## VerletCloth2D.gd
## Provides realistic, physics-based movement for Capes, Scarves, or Flags.
## This uses Verlet Integration to simulate string/cloth physics.
## 
## Node Hierarchy:
## Node2D (VerletCloth2D)
## └── Line2D (Visual representation)

extends Node2D

@export var points_count: int = 10
@export var point_distance: float = 5.0
@export var gravity: Vector2 = Vector2(0, 980)
@export var friction: float = 0.99
@export var wind_noise_scale: float = 0.1

var points: Array = []
var prev_points: Array = []

@onready var line: Line2D = $Line2D

func _ready() -> void:
	# Initialize points
	for i in range(points_count):
		points.append(global_position + Vector2(0, i * point_distance))
		prev_points.append(global_position + Vector2(0, i * point_distance))
	
	if not line:
		line = Line2D.new()
		add_child(line)
		line.width = 10.0
		# Apply a realistic gradient to the cape
		var g = Gradient.new()
		g.set_color(0, Color("#450a0a")) # Dark red top
		g.set_color(1, Color("#7f1d1d")) # Lighter red bottom
		line.gradient = g

func _physics_process(delta: float) -> void:
	# Pin first point to parent position
	points[0] = global_position
	
	# Simulate gravity and movement
	for i in range(1, points_count):
		var vel = (points[i] - prev_points[i]) * friction
		prev_points[i] = points[i]
		
		# Add wind effect using global wind parameter from EnvironmentalSystems
		var wind_force = RenderingServer.global_shader_parameter_get("wind_force")
		if wind_force == null: wind_force = 1.0
		var wind = Vector2(sin(Time.get_ticks_msec() * 0.005 + i) * wind_force * 20, 0)
		
		points[i] += vel + (gravity + wind) * delta * delta
		
	# Constraints (keep points distance constant)
	for j in range(5): # Iterations for stability
		for i in range(points_count - 1):
			var p1 = points[i]
			var p2 = points[i+1]
			var dist = p1.distance_to(p2)
			var diff = point_distance - dist
			var percent = diff / dist / 2
			var offset = (p2 - p1) * percent
			
			if i != 0: points[i] -= offset
			points[i+1] += offset

	# Update Line2D
	line.clear_points()
	for p in points:
		line.add_point(to_local(p))
