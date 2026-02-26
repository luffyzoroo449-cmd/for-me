## GameWorld.gd
## Attach to the root Node2D of each level scene
## Manages: level init, camera bounds, win/lose, particles, BGM, screen shake

extends Node2D

# ─── Signals ──────────────────────────────────────────────────────────────────
signal level_won(stars: int)
signal level_lost

# ─── Inspector ────────────────────────────────────────────────────────────────
@export var level_id: int = 1
@export var world_id: int = 1
@export var par_time: float = 60.0
@export var bgm_track: AudioStream

# ─── Internal ─────────────────────────────────────────────────────────────────
var elapsed_time: float = 0.0
var damage_taken: int = 0
var coins_collected: int = 0
var total_coins: int = 0
var enemies_defeated: int = 0
var is_level_active: bool = false
var camera_trauma: float = 0.0

# ─── Nodes ────────────────────────────────────────────────────────────────────
@onready var player_node: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var camera: Camera2D = $Player/Camera2D
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var particles_container: Node2D = $Particles

# Particle scene for runtime effects
const PARTICLE_SCENE := preload("res://scenes/effects/BurstParticle.tscn")

func _ready() -> void:
	add_to_group("game_world")
	_count_total_coins()
	_connect_player_signals()
	_connect_enemy_signals()
	_start_bgm()
	is_level_active = true

	# HUD init
	if hud:
		hud.get_node("HUD").init_level(level_id, world_id, player_node.health)

func _process(delta: float) -> void:
	if not is_level_active:
		return

	elapsed_time += delta
	_update_camera_shake(delta)

	if hud:
		hud.get_node("HUD").update_timer(elapsed_time)

# ─── Player Signals ───────────────────────────────────────────────────────────
func _connect_player_signals() -> void:
	player_node.health_changed.connect(_on_player_health_changed)
	player_node.died.connect(_on_player_died)
	player_node.coins_changed.connect(_on_coins_changed)
	player_node.get_node("WeaponManager").ammo_changed.connect(_on_ammo_changed)
	player_node.get_node("WeaponManager").weapon_changed.connect(_on_weapon_changed)
	player_node.get_node("WeaponManager").reload_started.connect(_on_reload_started)
	player_node.get_node("WeaponManager").reload_done.connect(_on_reload_done)

func _on_player_health_changed(new_health: int) -> void:
	damage_taken += 1
	if hud:
		hud.get_node("HUD").update_health(new_health)

func _on_player_died() -> void:
	is_level_active = false
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func _on_coins_changed(val: int) -> void:
	coins_collected = val
	if hud:
		hud.get_node("HUD").update_coins(val)

func _on_ammo_changed(current: int, max_ammo: int) -> void:
	if hud:
		hud.get_node("HUD").update_ammo(current, max_ammo)

func _on_weapon_changed(wid: String, data: Dictionary) -> void:
	if hud:
		hud.get_node("HUD").update_weapon(data["name"], data["bullet_color"])

func _on_reload_started() -> void:
	if hud:
		hud.get_node("HUD").show_reloading(true)

func _on_reload_done() -> void:
	if hud:
		hud.get_node("HUD").show_reloading(false)

# ─── Enemy Signals ────────────────────────────────────────────────────────────
func _connect_enemy_signals() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.died.connect(_on_enemy_died)

func _on_enemy_died(_enemy) -> void:
	enemies_defeated += 1
	GameManager.progress_mission("enemies", 1)

# ─── Called by enemies/bullets/traps ─────────────────────────────────────────
func on_enemy_defeated() -> void:
	enemies_defeated += 1

func on_coin_collected() -> void:
	coins_collected += 1

func get_level_id() -> int:
	return level_id

# ─── Exit Portal ─────────────────────────────────────────────────────────────
func on_exit_reached() -> void:
	if not is_level_active:
		return
	is_level_active = false
	_complete_level()

func _complete_level() -> void:
	var stars := _calculate_stars()
	var xp := _calculate_xp(stars)
	GameManager.complete_level(level_id, stars, xp, player_node.coins, player_node.gems)
	GameManager.progress_mission("levels", 1)

	# Show win screen
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/LevelComplete.tscn")

func _calculate_stars() -> int:
	if elapsed_time <= par_time and damage_taken == 0 and coins_collected >= int(total_coins * 0.8):
		return 3
	if elapsed_time <= par_time * 1.1 and damage_taken == 0:
		return 2
	return 1

func _calculate_xp(stars: int) -> int:
	var base := level_id * 10
	var speed_bonus := 30 if elapsed_time <= par_time else 0
	var no_damage_bonus := 20 if damage_taken == 0 else 0
	var star_bonus := (stars - 1) * 15
	return base + speed_bonus + no_damage_bonus + star_bonus

# ─── Camera Shake ─────────────────────────────────────────────────────────────
func camera_shake(intensity: float) -> void:
	camera_trauma = min(camera_trauma + intensity / 10.0, 1.0)

func _update_camera_shake(delta: float) -> void:
	if camera_trauma > 0:
		camera_trauma = max(0, camera_trauma - delta * 2.0)
		var shake := camera_trauma * camera_trauma  # quadratic feel
		camera.offset = Vector2(
			randf_range(-1, 1) * shake * 20,
			randf_range(-1, 1) * shake * 20
		)
	else:
		camera.offset = camera.offset.lerp(Vector2.ZERO, 0.3)

# ─── Particles ────────────────────────────────────────────────────────────────
func spawn_particles(config: Dictionary) -> void:
	if not PARTICLE_SCENE:
		return
	var p = PARTICLE_SCENE.instantiate()
	particles_container.add_child(p)
	p.global_position = config.get("position", Vector2.ZERO)
	p.emit(
		config.get("color", Color.WHITE),
		config.get("count", 8),
		config.get("type", "jump")
	)

# ─── BGM ─────────────────────────────────────────────────────────────────────
func _start_bgm() -> void:
	if bgm_track and GameManager.settings.get("music", true):
		bgm_player.stream = bgm_track
		bgm_player.play()

# ─── Coin Count ───────────────────────────────────────────────────────────────
func _count_total_coins() -> void:
	total_coins = get_tree().get_nodes_in_group("coin").size()

# ─── Respawn ──────────────────────────────────────────────────────────────────
func respawn_player() -> void:
	# For simplicity, reload current level on death
	get_tree().reload_current_scene()
