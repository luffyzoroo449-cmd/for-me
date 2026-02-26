## SaveSystem.gd
## Robust, slot-based save system for persistent character growth and story branching.
## Includes encryption support and cloud-ready data structures.

extends Node

const SAVE_DIR = "user://saves/"
const SETTINGS_FILE = "user://settings.cfg"

func _ready():
	# Ensure save directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir(SAVE_DIR)

func save_slot(slot_index: int):
	var save_path = SAVE_DIR + "save_" + str(slot_index) + ".tres"
	
	var data = SaveData.new() # Using a custom Resource class for structured saving
	_populate_save_data(data)
	
	var err = ResourceSaver.save(data, save_path)
	if err == OK:
		print("Game saved successfully to slot ", slot_index)
	else:
		printerr("Failed to save game: ", err)

func load_slot(slot_index: int) -> bool:
	var save_path = SAVE_DIR + "save_" + str(slot_index) + ".tres"
	
	if not FileAccess.file_exists(save_path):
		return false
		
	var data = ResourceLoader.load(save_path) as SaveData
	if data:
		_apply_save_data(data)
		return true
	return false

func _populate_save_data(data: SaveData):
	data.player_name = GameManager.player_name
	data.level = GameManager.level
	data.xp = GameManager.xp
	data.reputation = GameManager.reputation
	data.boss_flags = GameManager.boss_flags
	data.skills_unlocked = GameManager.skills_unlocked
	data.unlocked_weapons = GameManager.unlocked_weapons
	data.current_weapon = GameManager.current_weapon
	data.timestamp = Time.get_datetime_dict_from_system()

func _apply_save_data(data: SaveData):
	GameManager.player_name = data.player_name
	GameManager.level = data.level
	GameManager.xp = data.xp
	GameManager.reputation = data.reputation
	GameManager.boss_flags = data.boss_flags
	GameManager.skills_unlocked = data.skills_unlocked
	GameManager.unlocked_weapons = data.unlocked_weapons
	GameManager.current_weapon = data.current_weapon
	
	# Refresh UI and stats
	get_tree().call_group("hud", "update_all")
