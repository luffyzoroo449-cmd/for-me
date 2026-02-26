## HighFidelityCharacter.gd
## Base class for Player, Enemies, and NPCs.
## Handles skeleton-based secondary motion, anatomy-based muscle tension shaders,
## and dynamic lighting modulation for high-resolution (1024px) sprites.

extends CharacterBody2D

# --- Appearance Config ---
@export var muscle_tension_scale: float = 0.0 # 0.0: Relaxed, 1.0: Maximum Strain (Shader controlled)
@export var base_resolution_height: int = 1024

# --- Physics & Movement ---
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_active: bool = true

# --- Nodes ---
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var sprite: Sprite2D = $Visuals/MainSprite
@onready var skeleton: Skeleton2D = $Visuals/Skeleton2D

func _ready() -> void:
	animation_tree.active = true
	# Initialize muscle tension shader if present
	if sprite.material and sprite.material is ShaderMaterial:
		sprite.material.set_shader_parameter("tension", 0.0)

func apply_secondary_motion(delta: float) -> void:
	# Small procedural sway based on velocity
	if skeleton:
		var target_rotation = clamp(velocity.x * 0.001, -0.15, 0.15)
		# Assuming 'CapeRoot' or 'HairRoot' bones exist
		var cape_bone = skeleton.get_node_or_null("Torso/CapeRoot")
		if cape_bone:
			cape_bone.rotation = lerp(cape_bone.rotation, target_rotation, delta * 5.0)

func update_muscle_tension(action_intensity: float) -> void:
	# Called by AnimationPlayer tracks to highlight anatomy details during swings/jumps
	muscle_tension_scale = action_intensity
	if sprite.material:
		sprite.material.set_shader_parameter("tension", muscle_tension_scale)

func take_impact(direction: Vector2, force: float) -> void:
	velocity += direction * force
	# Trigger Hurt animation logic
	if animation_state:
		animation_state.travel("hurt")
	# Particle impact (Dust/Blood)
	get_tree().call_group("game_world", "spawn_particles", {
		"position": global_position + Vector2(0, -30),
		"type": "impact",
		"color": Color("#8a1c1c") # Deep realistic blood
	})
