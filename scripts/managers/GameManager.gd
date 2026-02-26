## GameManager.gd (Ultra-Realistic Update)
extends Node

# --- Core Stats ---
var hp: float = 100.0
var max_hp: float = 100.0
var mp: float = 50.0
var stamina: float = 100.0
var defense: float = 5.0
var attack_power: float = 15.0

# --- Progression ---
var player_name: String = "Luffy"
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

# --- Settings & Persistence ---
var settings = {"music": true, "sfx": true, "vibration": true}

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

func max_hp_boost():
	max_hp += 10.0
	hp = max_hp # Refill health on level up

func complete_level(level_id: int, stars: int, earned_xp: int, _coins: int, _gems: int):
	add_xp(earned_xp)
	# Logic for saving high scores or unlocking next level would go here
	print("Level %d Complete! Stars: %d, XP: %d" % [level_id, stars, earned_xp])
	save_game(1) # Auto-save to slot 1

func progress_mission(mission_id: String, amount: int):
	# Placeholder for mission tracking logic
	print("Mission Progress: %s +%d" % [mission_id, amount])

func update_reputation(amount: int):
	reputation = clamp(reputation + amount, -100, 100)
	# Notify StoryManager to check for branching paths
	get_tree().call_group("story", "check_reputation_events")

# --- Save/Load Logic ---
func save_game(slot: int):
	SaveSystem.save_slot(slot)

func load_game(slot: int):
	if SaveSystem.load_slot(slot):
		# Recalculate dynamic stats after load if needed
		max_hp = 100.0 + ((level - 1) * 10.0)
		hp = max_hp
		print("Loaded Slot %d: Level %d" % [slot, level])
	else:
		print("Failed to load slot %d" % slot)
