## ArcherAI.gd
## Advanced Ranged AI with Predictive Aiming.
## Calculates the player's future position based on velocity to land shots accurately.

extends "res://scripts/enemies/EnemyBase.gd"

@export var firing_arc: float = 0.5 # Random spread
@export var reload_time: float = 1.5

var is_reloading := false

func _physics_process(delta: float):
	if state == State.DEAD: return
	
	if player:
		_handle_predictive_aiming(delta)
	else:
		_do_patrol()

func _handle_predictive_aiming(_delta: float):
	if is_reloading: return
	
	var dist = global_position.distance_to(player.global_position)
	if dist < detect_range:
		# Stop and aim
		velocity.x = move_toward(velocity.x, 0, move_speed)
		
		# Predictive Logic:
		# We estimate how long the bullet takes to reach the player
		var travel_time = dist / bullet_speed
		# Current player velocity
		var player_vel = player.velocity
		# Predicted position: current_pos + (vel * time)
		var predicted_pos = player.global_position + (player_vel * travel_time)
		
		# Animation
		is_facing_right = predicted_pos.x > global_position.x
		sprite.flip_h = not is_facing_right
		sprite.play("aim")
		
		# Fire after a short delay
		is_reloading = true
		await get_tree().create_timer(0.4).timeout
		_fire_arrow(predicted_pos)

func _fire_arrow(target_pos: Vector2):
	if state == State.DEAD: return
	
	var direction = (target_pos - global_position).normalized()
	# Add slight inaccuracy
	direction = direction.rotated(randf_range(-0.05, 0.05))
	
	var bullet = ENEMY_BULLET.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = global_position + Vector2(sign(direction.x) * 15, -5)
	bullet.setup(direction * bullet_speed, bullet_damage)
	
	sprite.play("shoot")
	await get_tree().create_timer(reload_time).timeout
	is_reloading = false
