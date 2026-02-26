extends "res://scripts/core/HighFidelityCharacter.gd"

signal health_changed(new_health: int)
signal died
signal coins_changed(new_coins: int)

# --- Resources ---
var health: int:
	get: return int(GameManager.hp)
var coins: int = 0:
	set(val):
		coins = val
		coins_changed.emit(coins)
var gems: int = 0
var stamina: float = 100.0
var mp: float = 50.0
var oxygen: float = 100.0
var is_swimming := false
var is_alive := true
var is_facing_right := true

# --- Combat Stats ---
var combo_count: int = 0
var last_attack_time: float = 0.0
var combo_window: float = 0.6 # Seconds to chain next hit
var stamina_regen_rate: float = 15.0
@export var jump_velocity: float = -450.0

func _detect_floor_material() -> String:
	# Using RayCast2D or checking current floor group
	if is_on_floor():
		# Logic to check collision metadata or groups
		# For now, default to "stone"
		return "stone"
	return "stone"

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	_handle_stamina(delta)
	_handle_oxygen(delta)
	_handle_auto_ambient_sounds()
	apply_secondary_motion(delta)
	
	# Anatomy/Muscle Tension Feedback
	var intensity = velocity.length() / 250.0 # Scale with speed
	update_muscle_tension(clamp(intensity, 0.0, 1.0))
	
	var input = Input.get_axis("move_left", "move_right")
	if input != 0:
		is_facing_right = input > 0
	
	if Input.is_action_just_pressed("attack"):
		_perform_combo_attack()

func _handle_auto_ambient_sounds():
	# Low HP Heartbeat
	if GameManager.hp < 25 and not $HeartbeatPlayer.playing:
		$HeartbeatPlayer.play()
	elif GameManager.hp >= 25:
		$HeartbeatPlayer.stop()

func _perform_jump_logic():
	velocity.y = jump_velocity
	SoundManager.play_auto_sfx("jump", {"pitch_var": 0.2})

func play_footstep():
	# CALLED BY ANIMATIONPLAYER "Call Method" Track
	var material = _detect_floor_material()
	SoundManager.play_auto_sfx("step", {"material": material, "position": global_position})

func _handle_stamina(delta: float):
	if stamina < 100:
		stamina = move_toward(stamina, 100, stamina_regen_rate * delta)

func _handle_oxygen(delta: float):
	if is_swimming:
		oxygen -= 5.0 * delta
		if oxygen <= 0:
			take_damage(2.0 * delta) # Drowning damage
	else:
		oxygen = move_toward(oxygen, 100, 20.0 * delta)

func _perform_combo_attack():
	var now = Time.get_unix_time_from_system()
	
	# Check if we are still in the combo window
	if now - last_attack_time > combo_window:
		combo_count = 0
	
	if stamina < 20: return # Stamina check
	
	combo_count = (combo_count % 3) + 1
	last_attack_time = now
	stamina -= 15.0
	
	# Trigger Animation
	animation_state.travel("attack_" + str(combo_count))
	
	# Scale damage with combo
	var dmg_scale = 1.0 + (combo_count * 0.2)
	_apply_melee_damage(dmg_scale)

func take_damage(amount: float):
	GameManager.hp -= amount
	animation_state.travel("hurt")
	
	# Cinematic Feedback
	VFXManager.hit_stop(0.1)
	VFXManager.shake(5.0)
	SoundManager.play_auto_sfx("hurt", {"position": global_position})
	
	if GameManager.hp <= 0:
		died.emit()
		_die()
	else:
		health_changed.emit(int(GameManager.hp))

func _die():
	is_alive = false
	animation_state.travel("death")
	set_physics_process(false)
	await get_tree().create_timer(2.0).timeout
	get_tree().call_group("game_world", "respawn_player")

func _apply_melee_damage(scale: float):
	var hit_area: Area2D = $MeleeHitbox
	for body in hit_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			var base_dmg = 10
			body.take_damage(base_dmg * scale)
