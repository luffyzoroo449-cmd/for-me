## DestructibleObject.gd
## Realistic physics-based environmental destruction (crates, vases, pillars).
## On destruction, it spawns debris that reacts to gravity and physics.

extends StaticBody2D

@export var health: float = 20.0
@export var debris_count: int = 5
@export var debris_velocity: float = 200.0

# --- Debris Scene (Should be a small RigidBody2D) ---
@export var debris_scene: PackedScene

func take_damage(amount: float):
	if health <= 0: return
	
	health -= amount
	# Flash or shake purely for feedback
	_impact_visual()
	
	if health <= 0:
		_destroy()

func _impact_visual():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(2, 2, 2, 1), 0.05) # HDR White Flash
	tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.05)
	# Subtle shake
	var original_pos = $Sprite2D.position
	$Sprite2D.position += Vector2(randf_range(-2, 2), randf_range(-2, 2))
	await get_tree().create_timer(0.05).timeout
	$Sprite2D.position = original_pos

func _destroy():
	# 1. Sound & VFX
	SoundManager.play_auto_sfx("break_wood", {"position": global_position})
	get_tree().call_group("game_world", "camera_shake", 3.0)
	
	# 2. Spawn Physics Debris
	for i in range(debris_count):
		if debris_scene:
			var piece = debris_scene.instantiate() as RigidBody2D
			get_parent().add_child(piece)
			piece.global_position = global_position
			# Throw in random direction
			var dir = Vector2.UP.rotated(randf_range(-PI, PI))
			piece.apply_central_impulse(dir * randf_range(debris_velocity * 0.5, debris_velocity))
	
	# 3. Clean up
	queue_free()
