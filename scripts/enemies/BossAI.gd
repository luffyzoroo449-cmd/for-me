## BossAI.gd
## Extends EnemyBase — overrides _run_state with 4-phase boss fight
## 
## Boss phases:
##   Phase 1 (hp > 75%): Aggressive chase
##   Phase 2 (hp > 50%): Jump attacks + shoot
##   Phase 3 (hp > 25%): Charge attacks
##   Phase 4 (hp <= 25%): Teleport + multi-shot (FINAL BOSS only)

extends "res://scripts/enemies/EnemyBase.gd"

# ─── Boss Config ──────────────────────────────────────────────────────────────
@export var is_final_boss: bool = false
@export var boss_name: String = "Boss"

var phase: int = 1
var attack_tick: int = 0
var phase_timer: float = 0.0

const PHASE_CYCLE := 3.0   # seconds per full attack cycle

# ─── Override state runner ────────────────────────────────────────────────────
func _run_state(delta: float) -> void:
	if state == State.DEAD:
		return
	if not player:
		state = State.PATROL
		_do_patrol()
		return

	state = State.ATTACK
	_update_phase()
	_run_boss_phase(delta)

func _update_phase() -> void:
	var hp_frac := float(health) / float(max_health)
	if is_final_boss:
		if hp_frac > 0.75:   phase = 1
		elif hp_frac > 0.5:  phase = 2
		elif hp_frac > 0.25: phase = 3
		else:                phase = 4
	else:
		if hp_frac > 0.6:    phase = 1
		elif hp_frac > 0.3:  phase = 2
		else:                phase = 3

func _run_boss_phase(delta: float) -> void:
	phase_timer += delta
	if phase_timer > PHASE_CYCLE:
		phase_timer = 0.0

	var t := phase_timer / PHASE_CYCLE
	var dx := player.global_position.x - global_position.x
	var dir := sign(dx)
	is_facing_right = dir > 0
	sprite.flip_h = not is_facing_right

	match phase:
		1:
			# Aggressive Chase
			var speed_mult := 1.8 if is_final_boss else 1.4
			velocity.x = dir * move_speed * speed_mult

		2:
			# Jump + Shoot cycle
			if t < 0.33:
				# Jump toward player
				velocity.x = dir * move_speed
				if is_on_floor() and fmod(phase_timer, 1.0) < 0.05:
					velocity.y = -500.0
			elif t < 0.66:
				# Shoot burst
				if fmod(phase_timer, shoot_interval) < delta:
					_fire_boss_shot(dir)
			else:
				# Retreat
				velocity.x = -dir * move_speed * 0.5

		3:
			# Charge attack
			var charge_mult := 3.5 if is_final_boss else 2.8
			if t < 0.5:
				velocity.x = dir * move_speed * charge_mult
			else:
				velocity.x = move_toward(velocity.x, 0, move_speed)

		4:
			# Final boss: Teleport + multi-shot
			if fmod(phase_timer, 1.5) < delta:
				_teleport_near_player()
			if fmod(phase_timer, 0.5) < delta:
				_fire_spread_shot()

# ─── Boss Shoot ───────────────────────────────────────────────────────────────
func _fire_boss_shot(dir: float) -> void:
	var aim := Vector2(dir, 0)
	_spawn_boss_bullet(aim * bullet_speed * 1.2)

func _fire_spread_shot() -> void:
	for angle in [-0.3, 0.0, 0.3]:
		var aim := Vector2(1 if is_facing_right else -1, 0).rotated(angle)
		_spawn_boss_bullet(aim * bullet_speed)

func _spawn_boss_bullet(vel: Vector2) -> void:
	var bullet := ENEMY_BULLET.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = global_position
	bullet.setup(vel, bullet_damage)
	bullet.modulate = Color("#a855f7")

# ─── Teleport ─────────────────────────────────────────────────────────────────
func _teleport_near_player() -> void:
	if not player:
		return
	var offset := Vector2(-80 if is_facing_right else 80, 0)
	var target := player.global_position + offset

	# Particles at old position
	get_tree().call_group("game_world", "spawn_particles", {
		"position": global_position,
		"color": Color("#a855f7"), "count": 20, "type": "teleport"
	})
	global_position = target
	# Particles at new position
	get_tree().call_group("game_world", "spawn_particles", {
		"position": global_position,
		"color": Color("#a855f7"), "count": 20, "type": "teleport"
	})
	get_tree().call_group("game_world", "camera_shake", 10.0)

# ─── Override animation for boss ──────────────────────────────────────────────
func _update_animation() -> void:
	match state:
		State.DEAD:
			pass
		_:
			if abs(velocity.x) > 20:
				sprite.play("charge") if sprite.sprite_frames.has_animation("charge") else sprite.play("run")
			else:
				sprite.play("idle")
			# Rage tint
			if phase >= 3:
				sprite.modulate = Color(1.4, 0.6, 0.6)
			elif phase == 2:
				sprite.modulate = Color(1.2, 0.8, 0.8)
			else:
				sprite.modulate = Color.WHITE
