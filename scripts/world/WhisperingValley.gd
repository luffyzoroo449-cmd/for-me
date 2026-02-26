## WhisperingValley.gd
## The "Director" script for Level 12. 
## Manages section transitions, adaptive difficulty, and cutscene triggers.

extends Node2D

# ─── Sections ────────────────────────────────────────────────────────────────
@onready var environmental_systems = $EnvironmentalSystems
@onready var story_manager = $StoryManager
@onready var player = $Player
@onready var boss = $MiniBoss/ShadowCommander

var adaptive_difficulty_scale: float = 1.0
var section: int = 1 # 1: Forest, 2: Village, 3: Mountain, 4: Boss, 5: Ending

func _ready() -> void:
	add_to_group("game_world")
	# Initial Setup: Day lighting, calm forest
	environmental_systems.set_weather("clear")
	_apply_adaptive_difficulty()

func _process(_delta: float) -> void:
	_check_level_progression()

func _check_level_progression() -> void:
	var progress = player.global_position.x / 5000.0 # Assuming 5000px level length
	
	# Trigger Village Flashback (Section 2)
	if section == 1 and progress > 0.25:
		section = 2
		_trigger_village_entry()
	
	# Trigger Mountain Reverb (Section 3)
	if section == 2 and progress > 45.0:
		section = 3
		_enter_mountain_pass()

	# Trigger Boss Darkening (Section 4)
	if section == 3 and progress > 75.0:
		section = 4
		_initiate_boss_fight()

# ─── Adaptive Difficulty ──────────────────────────────────────────────────────
func _apply_adaptive_difficulty() -> void:
	var deaths = GameManager.get("deaths_this_session", 0)
	if deaths >= 3:
		adaptive_difficulty_scale = 0.8 # Nerf enemies
	elif GameManager.get("stars_average", 0) == 3:
		adaptive_difficulty_scale = 1.2 # Buff boss aggression
	
	# Communicate scale to enemy group
	get_tree().call_group("enemy", "set_difficulty_scale", adaptive_difficulty_scale)

# ─── Event Triggers ──────────────────────────────────────────────────────────
func _trigger_village_entry() -> void:
	story_manager.play_cutscene("village_flashback")
	environmental_systems.set_weather("fog")

func _enter_mountain_pass() -> void:
	# Increase wind particles and change audio reverb
	environmental_systems.wind_strength = 2.5
	AudioServer.set_bus_effect_enabled(1, 0, true) # Enable Reverb on SFX bus

func _initiate_boss_fight() -> void:
	# Lock the arena and darken sky
	$ArenaDoors.close()
	environmental_systems.transition_to_evening()
	boss.activate_boss()

func on_boss_defeated() -> void:
	section = 5
	story_manager.play_cutscene("victory_outro")
	environmental_systems.set_weather("clear")
	_spawn_reward_chest()
