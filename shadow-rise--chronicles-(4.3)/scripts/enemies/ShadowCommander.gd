## ShadowCommander.gd
## 3-Phase Boss AI for the Whispering Valley Arena.

extends "res://scripts/enemies/EnemyBase.gd"

enum BossState { IDLE, ATTACK_MELEE, ATTACK_DASH, SUMMON, TELEPORT, SLAM, RAGE }
var boss_state: BossState = BossState.IDLE

@export var phase: int = 1
var is_active := false

func _ready() -> void:
	max_health = 20
	super._ready()
	visible = false # Hidden until activated

func activate_boss() -> void:
	visible = true
	is_active = true
	_spawn_intro_particles()
	_start_phase_logic()

func _physics_process(delta: float) -> void:
	if not is_active or state == State.DEAD: return
	
	_update_phase()
	_run_phase_fsm(delta)

func _update_phase() -> void:
	var hp_pct = float(health) / float(max_health)
	if hp_pct > 0.6: phase = 1
	elif hp_pct > 0.3: phase = 2
	else: phase = 3

func _run_phase_fsm(_delta: float) -> void:
	if boss_state != BossState.IDLE: return
	
	# Decide next attack based on phase
	match phase:
		1: _decide_p1_attack()
		2: _decide_p2_attack()
		3: _decide_p3_attack()

# ─── Phase Actions ────────────────────────────────────────────────────────────
func _decide_p1_attack() -> void:
	boss_state = BossState.ATTACK_DASH if randf() > 0.5 else BossState.ATTACK_MELEE
	_execute_attack()

func _decide_p2_attack() -> void:
	var r = randf()
	if r > 0.7: boss_state = BossState.SUMMON
	elif r > 0.4: _fire_shadow_projectile()
	else: boss_state = BossState.ATTACK_DASH
	_execute_attack()

func _decide_p3_attack() -> void:
	# Aggressive Teleport and Slam
	boss_state = BossState.TELEPORT
	_execute_attack()

func _execute_attack() -> void:
	match boss_state:
		BossState.TELEPORT:
			_teleport_near_player()
			_perform_ground_slam()
		BossState.SUMMON:
			_spawn_minions()
		# Add more specific logic blocks for dash/melee...
	
	# Cooldown/Reset
	await get_tree().create_timer(1.0).timeout
	boss_state = BossState.IDLE

# ─── Attack Logic ─────────────────────────────────────────────────────────────
func _perform_ground_slam() -> void:
	sprite.play("slam")
	get_tree().call_group("game_world", "camera_shake", 8.0)
	# Trigger shockwave shock damage...
	
func _fire_shadow_projectile() -> void:
	# Instantiate shadow projectile scene...
	pass

func _spawn_minions() -> void:
	# Procedural spawning logic
	get_tree().call_group("game_world", "spawn_enemies", {"count": 2, "type": "basic"})

func _teleport_near_player() -> void:
	# Teleport particles...
	var target = player.global_position + Vector2(randf_range(-50, 50), -20)
	global_position = target
	get_tree().call_group("game_world", "spawn_particles", {"type": "teleport", "position": target})
