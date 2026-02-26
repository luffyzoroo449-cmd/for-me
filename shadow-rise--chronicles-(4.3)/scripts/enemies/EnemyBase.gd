## EnemyBase.gd
## Base class for ALL enemy types. Each enemy type extends this.
## Attach to: CharacterBody2D
##
## Scene structure:
##   CharacterBody2D (EnemyBase.gd)
##   ├── AnimatedSprite2D
##   ├── CollisionShape2D
##   ├── Area2D "DetectArea"     (CircleShape2D, radius = detect_range)
##   ├── Area2D "HitBox"         (CollisionShape2D)
##   ├── RayCast2D "EdgeCheck"   (points down-forward)
##   ├── Timer "ShootTimer"
##   ├── Timer "ReactionTimer"
##   ├── ProgressBar "HealthBar"
##   └── AudioStreamPlayer "SFX"
##
## States: PATROL → ALERT → ATTACK → DEAD

extends CharacterBody2D

# ─── Signals ──────────────────────────────────────────────────────────────────
signal died(enemy: CharacterBody2D)

# ─── Inspector Config ─────────────────────────────────────────────────────────
@export var enemy_type: String = "basic"   # basic | advanced | sniper | rusher | boss | shadow_stalker
@export var max_health: int = 1
@export var move_speed: float = 60.0
@export var patrol_range: float = 80.0
@export var detect_range: float = 180.0
@export var shoot_range: float = 0.0       # 0 = no shooting
@export var shoot_interval: float = 2.0
@export var reaction_delay: float = 0.4
@export var bullet_speed: float = 250.0
@export var bullet_damage: int = 1

@export var sfx_shoot: AudioStream
@export var sfx_die: AudioStream

# ─── Enemy Bullet Scene ───────────────────────────────────────────────────────
const ENEMY_BULLET := preload("res://scenes/weapons/EnemyBullet.tscn")

# ─── State Machine ────────────────────────────────────────────────────────────
enum State { PATROL, ALERT, ATTACK, DEAD }
var state: State = State.PATROL

# ─── Internal State ───────────────────────────────────────────────────────────
var health: int
var start_x: float
var patrol_dir: int = 1
var player: CharacterBody2D = null
var is_facing_right: bool = true
var alerted_timer: float = 0.0
var can_shoot: bool = true

# ─── Gravity ──────────────────────────────────────────────────────────────────
const GRAVITY := 1200.0
const MAX_FALL := 600.0

# ─── Nodes ────────────────────────────────────────────────────────────────────
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detect_area: Area2D = $DetectArea
@onready var hit_box: Area2D = $HitBox
@onready var edge_check: RayCast2D = $EdgeCheck
@onready var shoot_timer: Timer = $ShootTimer
@onready var reaction_timer: Timer = $ReactionTimer
@onready var health_bar: ProgressBar = $HealthBar
@onready var sfx_player: AudioStreamPlayer = $SFX

func _ready() -> void:
	health = max_health
	start_x = global_position.x
	add_to_group("enemy")

	# Connect detect area
	detect_area.body_entered.connect(_on_player_detected)
	detect_area.body_exited.connect(_on_player_lost)

	# Set up timers
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer)
	reaction_timer.wait_time = reaction_delay
	reaction_timer.one_shot = true
	reaction_timer.timeout.connect(_on_reaction_done)

	# Health bar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
		health_bar.visible = max_health > 1

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_apply_gravity(delta)
	_run_state(delta)
	_update_animation()
	move_and_slide()

# ─── State Runner ─────────────────────────────────────────────────────────────
func _run_state(_delta: float) -> void:
	match state:
		State.PATROL:
			_do_patrol()
		State.ALERT:
			pass  # Wait for reaction timer
		State.ATTACK:
			_do_attack()

# ─── Patrol ───────────────────────────────────────────────────────────────────
func _do_patrol() -> void:
	var dist_from_start := global_position.x - start_x
	if abs(dist_from_start) >= patrol_range:
		patrol_dir *= -1

	# Edge check — don't walk off platforms
	if edge_check and not edge_check.is_colliding():
		patrol_dir *= -1

	velocity.x = patrol_dir * move_speed
	is_facing_right = patrol_dir > 0
	sprite.flip_h = not is_facing_right

# ─── Attack ───────────────────────────────────────────────────────────────────
func _do_attack() -> void:
	if not player:
		state = State.PATROL
		return

	var dx := player.global_position.x - global_position.x
	var dist := abs(dx)

	# Lost player
	if dist > detect_range * 1.5:
		state = State.PATROL
		return

	is_facing_right = dx > 0
	sprite.flip_h = not is_facing_right
	var dir := sign(dx)

	if shoot_range > 0 and dist <= shoot_range:
		# Stop and shoot
		velocity.x = move_toward(velocity.x, 0, move_speed)
	else:
		# Chase
		velocity.x = dir * move_speed

# ─── Detection ────────────────────────────────────────────────────────────────
func _on_player_detected(body: Node) -> void:
	if body.is_in_group("player"):
		player = body
		if state == State.PATROL:
			state = State.ALERT
			reaction_timer.start()

func _on_player_lost(body: Node) -> void:
	if body.is_in_group("player"):
		if state == State.ATTACK:
			state = State.PATROL
		player = null

func _on_reaction_done() -> void:
	if player and state == State.ALERT:
		state = State.ATTACK
		if shoot_range > 0:
			shoot_timer.start()
		# Alert flash particle
		get_tree().call_group("game_world", "spawn_particles", {
			"position": global_position + Vector2(0, -30),
			"color": Color.RED,
			"count": 4, "type": "alert"
		})

# ─── Shooting ─────────────────────────────────────────────────────────────────
func _on_shoot_timer() -> void:
	if state != State.ATTACK or not player:
		return

	var dist := global_position.distance_to(player.global_position)
	if dist > shoot_range:
		return

	# Aim at player
	var aim := (player.global_position - global_position).normalized()
	var bullet := ENEMY_BULLET.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = global_position + Vector2(sign(aim.x) * 20, 0)
	bullet.setup(aim * bullet_speed, bullet_damage)

	if sfx_shoot and GameManager.settings.get("sfx", true):
		sfx_player.stream = sfx_shoot
		sfx_player.play()

	get_tree().call_group("game_world", "spawn_particles", {
		"position": bullet.global_position,
		"color": Color("#fca5a5"), "count": 3, "type": "muzzle"
	})

# ─── Damage ───────────────────────────────────────────────────────────────────
func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	health -= amount
	if health_bar:
		health_bar.value = health

	# Knockback from bullet direction
	var knock_dir := Vector2(-1 if is_facing_right else 1, -0.3).normalized()
	velocity = knock_dir * 150

	# Flash red
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.08)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.08)

	if health <= 0:
		_die()

func _die() -> void:
	state = State.DEAD
	shoot_timer.stop()
	set_physics_process(false)
	sprite.play("die")
	emit_signal("died", self)

	if sfx_die and GameManager.settings.get("sfx", true):
		sfx_player.stream = sfx_die
		sfx_player.play()

	get_tree().call_group("game_world", "spawn_particles", {
		"position": global_position,
		"color": Color.RED, "count": 16, "type": "death"
	})
	get_tree().call_group("game_world", "on_enemy_defeated")

	# Wait for animation, then hide
	await sprite.animation_finished
	queue_free()

# ─── Stomped by player ────────────────────────────────────────────────────────
func on_stomped(player_node: CharacterBody2D) -> void:
	take_damage(1)
	# Bounce player up
	player_node.velocity.y = -350.0

# ─── Gravity ──────────────────────────────────────────────────────────────────
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL)

# ─── Animation ────────────────────────────────────────────────────────────────
func _update_animation() -> void:
	match state:
		State.DEAD:
			pass
		State.PATROL:
			sprite.play("walk")
		State.ALERT:
			sprite.play("alert") if sprite.sprite_frames.has_animation("alert") else sprite.play("idle")
		State.ATTACK:
			if abs(velocity.x) > 5:
				sprite.play("run") if sprite.sprite_frames.has_animation("run") else sprite.play("walk")
			else:
				sprite.play("shoot") if sprite.sprite_frames.has_animation("shoot") else sprite.play("idle")
