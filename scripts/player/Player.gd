## Player.gd
## Attach to: CharacterBody2D node named "Player"
##
## Node structure needed:
##   CharacterBody2D (Player)
##   ├── AnimatedSprite2D        (@onready var sprite)
##   ├── CollisionShape2D
##   ├── Camera2D
##   ├── Marker2D "MuzzlePoint"  (bullet spawn)
##   ├── Timer "CoyoteTimer"     (wait_time = 0.1)
##   ├── Timer "JumpBuffer"      (wait_time = 0.05)
##   ├── Timer "DashCooldown"    (wait_time = 1.5)
##   ├── Timer "InvincibilityTimer" (wait_time = 1.0)
##   ├── Area2D "HurtBox"
##   └── AudioStreamPlayer "SFX"

extends CharacterBody2D

# ─── Signals ──────────────────────────────────────────────────────────────────
signal health_changed(new_health)
signal died
signal coins_changed(new_coins)
signal gems_changed(new_gems)

# ─── Stats ────────────────────────────────────────────────────────────────────
const MOVE_SPEED    := 200.0
const JUMP_FORCE    := -500.0
const DBL_JUMP_FORCE:= -420.0
const DASH_FORCE    := 700.0
const DASH_DURATION := 0.15
const GRAVITY       := 1200.0
const MAX_FALL_SPEED:= 800.0
const MAX_HEALTH    := 3

# ─── State ────────────────────────────────────────────────────────────────────
var health: int = MAX_HEALTH
var coins: int = 0
var gems: int = 0
var is_alive: bool = true
var is_grounded: bool = false
var can_double_jump: bool = true
var can_dash: bool = true
var is_dashing: bool = false
var is_invincible: bool = false
var is_facing_right: bool = true
var dash_timer: float = 0.0
var skin_color: Color = Color("#7c3aed")

# ─── Nodes ────────────────────────────────────────────────────────────────────
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $MuzzlePoint
@onready var sfx: AudioStreamPlayer = $SFX
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBuffer
@onready var dash_cooldown: Timer = $DashCooldown
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var weapon_manager: Node = $WeaponManager

# ─── SFX Sounds (assign in Inspector) ────────────────────────────────────────
@export var sfx_jump: AudioStream
@export var sfx_double_jump: AudioStream
@export var sfx_dash: AudioStream
@export var sfx_damage: AudioStream
@export var sfx_death: AudioStream
@export var sfx_land: AudioStream

# ─── Const ────────────────────────────────────────────────────────────────────
const BULLET_SCENE = preload("res://scenes/weapons/Bullet.tscn")

func _ready() -> void:
	health = MAX_HEALTH
	_update_animation()

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	_apply_gravity(delta)
	_handle_movement()
	_handle_jump()
	_handle_dash(delta)
	_update_animation()
	move_and_slide()

	is_grounded = is_on_floor()
	if is_grounded:
		can_double_jump = true
		coyote_timer.start()

# ─── Movement ─────────────────────────────────────────────────────────────────
func _handle_movement() -> void:
	if is_dashing:
		return
	var dir := 0.0
	if Input.is_action_pressed("move_left"):
		dir = -1.0
		is_facing_right = false
	elif Input.is_action_pressed("move_right"):
		dir = 1.0
		is_facing_right = true
	else:
		velocity.x = move_toward(velocity.x, 0, MOVE_SPEED * 0.3)
		return

	velocity.x = dir * MOVE_SPEED
	sprite.flip_h = not is_facing_right

# ─── Gravity ──────────────────────────────────────────────────────────────────
func _apply_gravity(delta: float) -> void:
	if is_dashing:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)

# ─── Jump ─────────────────────────────────────────────────────────────────────
func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or not coyote_timer.is_stopped():
			_do_jump(JUMP_FORCE)
			_play_sfx(sfx_jump)
		elif can_double_jump:
			can_double_jump = false
			_do_jump(DBL_JUMP_FORCE)
			_play_sfx(sfx_double_jump)
			_spawn_jump_particles(true)
		else:
			jump_buffer_timer.start()

	# Jump buffer: if landed while buffer active, jump
	if not jump_buffer_timer.is_stopped() and is_on_floor():
		_do_jump(JUMP_FORCE)
		jump_buffer_timer.stop()

func _do_jump(force: float) -> void:
	velocity.y = force
	_spawn_jump_particles(false)

# ─── Dash ─────────────────────────────────────────────────────────────────────
func _handle_dash(delta: float) -> void:
	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		is_dashing = true
		dash_timer = DASH_DURATION
		var dir := 1.0 if is_facing_right else -1.0
		velocity = Vector2(dir * DASH_FORCE, 0)
		_play_sfx(sfx_dash)
		_spawn_dash_particles()
		dash_cooldown.start()

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			velocity.x = 0.0

func _on_dash_cooldown_timeout() -> void:
	can_dash = true

# ─── Animation ────────────────────────────────────────────────────────────────
func _update_animation() -> void:
	if not is_alive:
		sprite.play("die")
		return
	if is_dashing:
		sprite.play("dash")
	elif not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	elif abs(velocity.x) > 10:
		sprite.play("run")
	else:
		sprite.play("idle")

# ─── Damage ───────────────────────────────────────────────────────────────────
func take_damage(amount: int = 1) -> void:
	if is_invincible or not is_alive:
		return
	health -= amount
	emit_signal("health_changed", health)
	_play_sfx(sfx_damage)
	is_invincible = true
	invincibility_timer.start()

	# Camera shake — tell GameWorld
	get_tree().call_group("game_world", "camera_shake", 5.0)

	# Flash red
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if health <= 0:
		_die()

func _on_invincibility_timer_timeout() -> void:
	is_invincible = false

func _die() -> void:
	is_alive = false
	_play_sfx(sfx_death)
	velocity = Vector2.ZERO
	emit_signal("died")
	sprite.play("die")
	set_physics_process(false)

# ─── Collect ──────────────────────────────────────────────────────────────────
func collect_coin(value: int = 1) -> void:
	coins += value
	emit_signal("coins_changed", coins)
	get_tree().call_group("game_world", "on_coin_collected")

func collect_gem(value: int = 10) -> void:
	gems += value
	emit_signal("gems_changed", gems)

# ─── Particles ────────────────────────────────────────────────────────────────
func _spawn_jump_particles(is_double: bool) -> void:
	get_tree().call_group("game_world", "spawn_particles", {
		"position": global_position + Vector2(0, 16),
		"color": Color("#e2e8f0") if not is_double else skin_color,
		"count": 6,
		"type": "jump"
	})

func _spawn_dash_particles() -> void:
	get_tree().call_group("game_world", "spawn_particles", {
		"position": global_position,
		"color": skin_color,
		"count": 12,
		"type": "dash"
	})

# ─── SFX Helper ───────────────────────────────────────────────────────────────
func _play_sfx(stream: AudioStream) -> void:
	if stream and GameManager.settings.get("sfx", true):
		sfx.stream = stream
		sfx.play()
