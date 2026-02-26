## WeaponUnlockManager.gd
## Logic for unlocking weapons based on Level, Bosses, and Quests.

extends Node

const WEAPON_REQUIREMENTS = {
	"dual_blades": {"level": 10},
	"great_sword": {"level": 20},
	"fire_blade": {"boss": "lava"},
	"ice_katana": {"quest": "ice_cave"},
	"legendary_shadow": {"reputation": -80, "boss": "shadow"} # Dark Path unlock
}

func check_unlocks():
	for weapon in WEAPON_REQUIREMENTS:
		if weapon in GameManager.unlocked_weapons: continue
		
		var reqs = WEAPON_REQUIREMENTS[weapon]
		var met = true
		
		if reqs.has("level") and GameManager.level < reqs["level"]: met = false
		if reqs.has("boss") and not GameManager.boss_flags[reqs["boss"]]: met = false
		if reqs.has("quest") and not GameManager.quest_flags[reqs["quest"]]: met = false
		if reqs.has("reputation") and GameManager.reputation > reqs["reputation"]: met = false # Requirement for "Evil" reputation
		
		if met:
			_unlock_weapon(weapon)

func _unlock_weapon(id: String):
	GameManager.unlocked_weapons.append(id)
	get_tree().call_group("hud", "show_unlock_notification", id)
	# Play cinematic sound
