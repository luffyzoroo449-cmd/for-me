## GameManager.gd (Ultra-Realistic Update)
extends Node

# --- Core Stats ---
var hp: float = 100.0
var mp: float = 50.0
var stamina: float = 100.0
var defense: float = 5.0
var attack_power: float = 15.0

# --- Progression ---
var level: int = 1
var xp: int = 0
var skill_points: int = 0
var reputation: int = 0 # -100 (Evil) to +100 (Hero)

# --- Flag Tracking (For Unlocks & Story) ---
var boss_flags = {"lava": false, "water": false, "shadow": false}
var quest_flags = {"ice_cave": false, "village_traitor": false}
var skills_unlocked = [] # ["double_jump", "shadow_dash"]

# --- Weapon & Inventory ---
var unlocked_weapons = ["steel_sword"]
var current_weapon = "steel_sword"

func add_xp(amount: int):
	xp += amount
	if xp >= _get_next_level_xp():
		_level_up()

func _get_next_level_xp(): return level * 100 * 1.5

func _level_up():
	level += 1
	skill_points += 2
	max_hp_boost()
	get_tree().call_group("hud", "show_level_up", level)

func update_reputation(amount: int):
	reputation = clamp(reputation + amount, -100, 100)
	# Notify StoryManager to check for branching paths
	get_tree().call_group("story", "check_reputation_events")

# --- Save/Load Logic ---
func save_game(slot: int):
	var data = {
		"level": level, "xp": xp, "reputation": reputation,
		"unlocked_weapons": unlocked_weapons, "flags": boss_flags
	}
	var file = FileAccess.open("user://save_slot_" + str(slot) + ".dat", FileAccess.WRITE)
	file.store_var(data)

func load_game(slot: int):
	if FileAccess.file_exists("user://save_slot_" + str(slot) + ".dat"):
		var file = FileAccess.open("user://save_slot_" + str(slot) + ".dat", FileAccess.READ)
		var data = file.get_var()
		# Populate game state...
