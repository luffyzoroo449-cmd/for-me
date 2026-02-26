## WeaponManager.gd
## Attach as child Node of Player
## Handles: weapon switching, ammo, reload, fire, bullet spawning, recoil

extends Node

# ─── Weapon Definitions ───────────────────────────────────────────────────────
const WEAPONS := {
	"pistol": {
		"name": "Pistol", "emoji": "🔫",
		"damage": 1, "range": 200.0, "fire_rate": 0.4,
		"bullet_speed": 400.0, "bullet_size": 5.0,
		"magazine": 8, "reload_time": 1.5,
		"recoil": 40.0, "pellets": 1, "spread": 0.0,
		"bullet_color": Color("#fde047"), "flash_color": Color("#fef9c3"),
		"is_auto": false, "unlock_level": 1,
	},
	"smg": {
		"name": "SMG", "emoji": "🔫",
		"damage": 1, "range": 250.0, "fire_rate": 0.12,
		"bullet_speed": 500.0, "bullet_size": 4.0,
		"magazine": 20, "reload_time": 2.0,
		"recoil": 20.0, "pellets": 1, "spread": 0.05,
		"bullet_color": Color("#fb923c"), "flash_color": Color("#fed7aa"),
		"is_auto": true, "unlock_level": 10,
	},
	"shotgun": {
		"name": "Shotgun", "emoji": "🔫",
		"damage": 2, "range": 130.0, "fire_rate": 0.9,
		"bullet_speed": 550.0, "bullet_size": 6.0,
		"magazine": 6, "reload_time": 2.5,
		"recoil": 120.0, "pellets": 5, "spread": 0.35,
		"bullet_color": Color("#f97316"), "flash_color": Color("#ffedd5"),
		"is_auto": false, "unlock_level": 20,
	},
	"assault_rifle": {
		"name": "Assault Rifle", "emoji": "🔫",
		"damage": 2, "range": 350.0, "fire_rate": 0.2,
		"bullet_speed": 650.0, "bullet_size": 4.0,
		"magazine": 30, "reload_time": 2.2,
		"recoil": 50.0, "pellets": 1, "spread": 0.02,
		"bullet_color": Color("#38bdf8"), "flash_color": Color("#e0f2fe"),
		"is_auto": true, "unlock_level": 40,
	},
	"sniper": {
		"name": "Sniper", "emoji": "🎯",
		"damage": 5, "range": 700.0, "fire_rate": 1.5,
		"bullet_speed": 900.0, "bullet_size": 5.0,
		"magazine": 5, "reload_time": 3.5,
		"recoil": 200.0, "pellets": 1, "spread": 0.0,
		"bullet_color": Color("#c084fc"), "flash_color": Color("#f3e8ff"),
		"is_auto": false, "unlock_level": 60,
	},
}

const WEAPON_ORDER := ["pistol", "smg", "shotgun", "assault_rifle", "sniper"]
const BULLET_SCENE := preload("res://scenes/weapons/Bullet.tscn")

# ─── State ────────────────────────────────────────────────────────────────────
var current_weapon_id: String = "pistol"
var ammo: int = 8
var is_reloading: bool = false
var fire_cooldown: float = 0.0
var muzzle_flash_timer: float = 0.0

# ─── Signals ──────────────────────────────────────────────────────────────────
signal ammo_changed(current, max_ammo)
signal weapon_changed(weapon_id, weapon_data)
signal reload_started
signal reload_done

# ─── Nodes ────────────────────────────────────────────────────────────────────
@onready var player: CharacterBody2D = get_parent()
@onready var reload_timer: Timer = $ReloadTimer
@onready var muzzle_flash: Sprite2D = get_parent().get_node("Visuals/MuzzlePoint/MuzzleFlash")

func _ready() -> void:
	_equip_weapon("pistol")
	reload_timer.timeout.connect(_on_reload_done)
	if muzzle_flash:
		muzzle_flash.visible = false

func _process(delta: float) -> void:
	if fire_cooldown > 0:
		fire_cooldown -= delta

	# Muzzle flash fade
	if muzzle_flash_timer > 0:
		muzzle_flash_timer -= delta
		if muzzle_flash_timer <= 0 and muzzle_flash:
			muzzle_flash.visible = false

func _physics_process(_delta: float) -> void:
	if is_reloading or not player.is_alive:
		return

	var def := get_current_def()

	# Cycle weapon
	if Input.is_action_just_pressed("cycle_weapon"):
		_cycle_weapon()

	# Manual reload
	if Input.is_action_just_pressed("reload") and ammo < def["magazine"]:
		_start_reload()
		return

	# Auto-reload on empty
	if ammo <= 0 and not is_reloading:
		_start_reload()
		return

	# Shoot
	if fire_cooldown <= 0.0:
		var should_fire := false
		if def["is_auto"]:
			should_fire = Input.is_action_pressed("shoot")
		else:
			should_fire = Input.is_action_just_pressed("shoot")

		if should_fire and ammo > 0:
			_fire()

# ─── Fire ─────────────────────────────────────────────────────────────────────
func _fire() -> void:
	var def := get_current_def()
	ammo -= 1
	fire_cooldown = def["fire_rate"]
	emit_signal("ammo_changed", ammo, def["magazine"])

	var muzzle_node = player.get_node_or_null("Visuals/MuzzlePoint")
	var muzzle_pos: Vector2
	var dir := 1.0 if player.is_facing_right else -1.0
	
	if muzzle_node:
		muzzle_pos = muzzle_node.global_position
	else:
		# Fallback: simple offset from player center
		muzzle_pos = player.global_position + Vector2(dir * 25, -30)

	# Spawn pellets
	for i in range(def["pellets"]):
		var spread_angle := (randf() - 0.5) * def["spread"]
		var bdir := Vector2(dir, 0).rotated(spread_angle)
		var bullet = BULLET_SCENE.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = muzzle_pos
		bullet.setup(
			bdir * def["bullet_speed"],
			def["damage"],
			def["range"],
			def["bullet_color"],
			def["bullet_size"]
		)

	# Recoil
	player.velocity.x -= dir * def["recoil"]

	# Muzzle flash
	if muzzle_flash:
		muzzle_flash.visible = true
		muzzle_flash.modulate = def["flash_color"]
		muzzle_flash_timer = 0.06

	# Particles
	get_tree().call_group("game_world", "spawn_particles", {
		"position": muzzle_pos,
		"color": def["flash_color"],
		"count": 4, "type": "muzzle"
	})

	# Camera shake (sniper / shotgun)
	if def["recoil"] > 100:
		get_tree().call_group("game_world", "camera_shake", 3.0)

# ─── Reload ───────────────────────────────────────────────────────────────────
func _start_reload() -> void:
	if is_reloading:
		return
	is_reloading = true
	emit_signal("reload_started")
	reload_timer.wait_time = get_current_def()["reload_time"]
	reload_timer.start()

func _on_reload_done() -> void:
	ammo = get_current_def()["magazine"]
	is_reloading = false
	emit_signal("reload_done")
	emit_signal("ammo_changed", ammo, ammo)

# ─── Cycle Weapon ─────────────────────────────────────────────────────────────
func _cycle_weapon() -> void:
	var level_id: int = get_tree().call_group_flags(0, "game_world", "get_level_id")
	var available := WEAPON_ORDER.filter(
		func(id): return WEAPONS[id]["unlock_level"] <= level_id
	)
	if available.size() == 0:
		return
	var idx: int = available.find(current_weapon_id)
	var next_id: String = available[(idx + 1) % available.size()]
	_equip_weapon(next_id)

func _equip_weapon(weapon_id: String) -> void:
	current_weapon_id = weapon_id
	var def := get_current_def()
	ammo = def["magazine"]
	is_reloading = false
	fire_cooldown = 0.0
	emit_signal("weapon_changed", weapon_id, def)
	emit_signal("ammo_changed", ammo, def["magazine"])

# ─── Helpers ──────────────────────────────────────────────────────────────────
func get_current_def() -> Dictionary:
	return WEAPONS.get(current_weapon_id, WEAPONS["pistol"])

func get_ammo_fraction() -> float:
	var mag := get_current_def()["magazine"]
	return float(ammo) / float(mag) if mag > 0 else 0.0
