## WaterPhantomAI.gd
## Stealth AI that remains hidden underwater and lunges at the player.

extends "res://scripts/enemies/EnemyBase.gd"

enum WaterState { SUBMERGED, EMERGING, ATTACKING, RETREATING }
var water_state: WaterState = WaterState.SUBMERGED

func _ready():
	super._ready()
	visible = false
	collision_layer = 0 # Inactive while submerged

func _physics_process(delta: float):
	match water_state:
		WaterState.SUBMERGED:
			_check_for_ambush()
		WaterState.EMERGING:
			pass # Managed by animation callback
		WaterState.ATTACKING:
			_do_lunge(delta)
		WaterState.RETREATING:
			_submerge()

func _check_for_ambush():
	if player and global_position.distance_to(player.global_position) < 150:
		_emerge()

func _emerge():
	water_state = WaterState.EMERGING
	visible = true
	sprite.play("emerge")
	# Sound & Particles
	get_tree().call_group("game_world", "spawn_particles", {"type": "splash", "position": global_position})
	
	await sprite.animation_finished
	water_state = WaterState.ATTACKING
	collision_layer = 16 # Become tangible

func _do_lunge(_delta: float):
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * move_speed * 3.0
	move_and_slide()
	
	if global_position.distance_to(player.global_position) < 40:
		player.take_damage(bullet_damage)
		water_state = WaterState.RETREATING

func _submerge():
	water_state = WaterState.SUBMERGED
	sprite.play_backwards("emerge")
	await sprite.animation_finished
	visible = false
	collision_layer = 0
