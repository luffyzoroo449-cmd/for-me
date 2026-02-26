## AssassinAI.gd
## High-tier AI: Uses stealth (invisibility) and teleportation behind the player.

extends "res://scripts/enemies/EnemyBase.gd"

enum StealthState { HIDDEN, STALKING, ATTACKING }
var stealth_state: StealthState = StealthState.HIDDEN

@export var vanish_cooldown: float = 4.0
var can_vanish := true

func _ready():
	super._ready()
	_vanish()

func _physics_process(delta: float):
	if state == State.DEAD: return
	
	match stealth_state:
		StealthState.HIDDEN:
			_stalk_player(delta)
		StealthState.ATTACKING:
			_perform_strike()

func _stalk_player(_delta: float):
	if not player: return
	
	var dist = global_position.distance_to(player.global_position)
	
	if dist < 80:
		_unveil_and_attack()
	else:
		# Ghostly movement toward player's back
		var target_x = player.global_position.x - (80 * sign(player.velocity.x if player.velocity.x != 0 else 1.0))
		global_position.x = lerp(global_position.x, target_x, 0.05)

func _unveil_and_attack():
	stealth_state = StealthState.ATTACKING
	# Appear behind
	var teleport_offset = Vector2(-40 if player.is_facing_right else 40, 0)
	global_position = player.global_position + teleport_offset
	
	# Visuals
	modulate.a = 1.0
	sprite.play("attack_critical")
	get_tree().call_group("game_world", "spawn_particles", {"type": "teleport", "position": global_position})
	
	await sprite.animation_finished
	_vanish()

func _vanish():
	stealth_state = StealthState.HIDDEN
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	can_vanish = false
	await get_tree().create_timer(vanish_cooldown).timeout
	can_vanish = true

func _perform_strike():
	# Striking is handled in animation frames or the unviel function
	pass

func take_damage(amount: int):
	if stealth_state == StealthState.HIDDEN:
		_unveil_and_attack() # Force reveal on hit
	super.take_damage(amount)
