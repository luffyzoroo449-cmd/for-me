## SaveData.gd
## Resource class for structuring save data efficiently.

extends Resource
class_name SaveData

@export var player_name: String
@export var level: int
@export var xp: int
@export var reputation: int
@export var boss_flags: Dictionary
@export var skills_unlocked: Array
@export var unlocked_weapons: Array
@export var current_weapon: String
@export var timestamp: Dictionary
