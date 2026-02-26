## HeavyKnightAI.gd
## Features: Shield Blocking, Ground Slam AOE, and Heavy Impact SFX.

extends "res://scripts/enemies/EnemyBase.gd"

var is_blocking := false
var is_slamming := false

@export var block_chance: float = 0.6
@export var slam_cooldown: float = 5.0
var _can_slam := true

func _physics_process(delta: float):
	if state == State.DEAD: return
	
	if player:
		_process_combat_logic()
	else:
		_do_patrol()

func _process_combat_logic():
	var dist = global_position.distance_to(player.global_position)
	
	if dist < 60 and _can_slam:
		_perform_ground_slam()
	elif dist < 120:
		# Slow, heavy walk
		velocity.x = sign(player.global_position.x - global_position.x) * (move_speed * 0.5)
	
func _perform_ground_slam():
	_can_slam = false
	is_slamming = true
	velocity.x = 0
	
	sprite.play("ground_slam")
	# Sound: Heavy impact
	SoundManager.play_auto_sfx("impact_heavy", {"position": global_position})
	
	# Wait for animation frame
	await get_tree().create_timer(0.6).timeout
	get_tree().call_group("game_world", "camera_shake", 10.0)
	# Trigger damage in Area2D
	
	await get_tree().create_timer(slam_cooldown).timeout
	_can_slam = true
	is_slamming = false

func take_damage(amount: int):
	# Automatic Block Logic
	if not is_slamming and randf() < block_chance:
		is_blocking = true
		sprite.play("block")
		# Sound: Metal spark/clang
		SoundManager.play_auto_sfx("clash", {"position": global_position})
		return # Negate damage
	
	super.take_damage(amount)
