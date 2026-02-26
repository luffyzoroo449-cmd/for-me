## CombatPhysics.gd
## Adds professional weight to combat: Swing Drag, Hit-Stop, and Recoil.

extends Node

# --- Config ---
@export var swing_drag_strength: float = 0.15 # Delay for the sprite to catch up to the hand
@export var impact_freeze_time: float = 0.08  # "Hit-Stop" duration in seconds

@onready var parent = get_parent() # The CharacterBody2D
@onready var weapon_visual = parent.get_node("Visuals/WeaponSprite")

func _process(delta: float):
	_apply_weapon_drag(delta)

func _apply_weapon_drag(delta: float):
	if not weapon_visual: return
	
	# Realistic Weapon Drag: The weapon lags slightly behind the character's movement
	# This makes it feel heavy and physical rather than "glued" to the hand
	var target_rot = parent.velocity.x * -0.0005
	weapon_visual.rotation = lerp_angle(weapon_visual.rotation, target_rot, delta * 5.0)

func apply_impact_feel():
	# 1. Hit-Stop (Time dilation)
	Engine.time_scale = 0.05
	await get_tree().create_timer(impact_freeze_time * 0.05).timeout
	Engine.time_scale = 1.0
	
	# 2. Camera Shake
	get_tree().call_group("game_world", "camera_shake", 5.0)
	
	# 3. Recoil
	var recoil_dir = Vector2(-1 if parent.is_facing_right else 1, 0)
	parent.velocity += recoil_dir * 150.0 # Push character back slightly
