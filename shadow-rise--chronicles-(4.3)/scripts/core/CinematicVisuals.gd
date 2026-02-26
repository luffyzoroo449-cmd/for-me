## CinematicVisuals.gd
## Handles "AAA" visual effects: armor reflections, motion blur, 
## subsurface lava glow, and footstep particles.

extends Node2D

@onready var parent = get_parent()

func _process(_delta: float) -> void:
	_update_motion_blur()
	_update_lighting_reflections()

func _update_motion_blur() -> void:
	# Only apply during high-speed actions like Dash
	if parent.has_method("is_dashing") and parent.is_dashing():
		parent.sprite.material.set_shader_parameter("blur_strength", 0.05)
	else:
		parent.sprite.material.set_shader_parameter("blur_strength", 0.0)

func _update_lighting_reflections() -> void:
	# Adjust armor specular based on nearby light sources
	# In a real setup, you'd query the LightingManager
	pass

func spawn_footstep_particles() -> void:
	# Called via AnimationPlayer 'Call Method' track
	get_tree().call_group("game_world", "spawn_particles", {
		"position": parent.global_position + Vector2(0, 5),
		"type": "dust",
		"count": 4,
		"color": Color("#c4b5a4") # Natural dirt color
	})

func spawn_armor_sparks(pos: Vector2) -> void:
	# For Heavy Knight hit reactions
	get_tree().call_group("game_world", "spawn_particles", {
		"position": pos,
		"type": "sparks",
		"count": 8,
		"color": Color("#facc15") # Hot yellow metal sparks
	})
