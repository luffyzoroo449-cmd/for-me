## LavaBeastAI.gd
## Specialized AI for Lava Zones. Immune to lava, uses fire breath and area of effect attacks.

extends "res://scripts/enemies/EnemyBase.gd"

@export var fire_breath_cooldown: float = 3.0
var _can_breathe_fire: bool = true

func _ready():
	super._ready()
	# Immunity to lava damage
	add_to_group("lava_immune")
	max_health = 150
	health = 150

func _run_state(delta: float):
	if state == State.DEAD: return
	
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < 150 and _can_breathe_fire:
			_perform_fire_breath()
		elif dist < 300:
			# Chase
			velocity.x = sign(player.global_position.x - global_position.x) * move_speed * 0.8
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed * delta)
	else:
		_do_patrol()

func _perform_fire_breath():
	_can_breathe_fire = false
	velocity.x = 0
	sprite.play("attack_fire")
	
	# Spawn fire particles/hitbox
	await get_tree().create_timer(1.0).timeout
	
	# Cooldown
	await get_tree().create_timer(fire_breath_cooldown).timeout
	_can_breathe_fire = true

func take_damage(amount: int):
	# Lava Beast might have armor/defense
	var actual_damage = clampi(amount - 2, 1, 999) 
	super.take_damage(actual_damage)
