## SkillTreeManager.gd
## Manages the unlocking of character abilities and stat boosts.

extends Node

# --- Skill Definitions ---
const SKILLS = {
	"double_jump": {"cost": 2, "req": [], "desc": "Allow a second jump mid-air."},
	"shadow_dash": {"cost": 3, "req": ["double_jump"], "desc": "A dash that grants brief invincibility."},
	"heavy_swing": {"cost": 2, "req": [], "desc": "Melee attacks deal 20% more damage."},
	"mana_regen": {"cost": 4, "req": ["heavy_swing"], "desc": "Slowly restore MP over time."}
}

# --- Signals ---
signal skill_unlocked(skill_id)
signal insufficient_points

func unlock_skill(skill_id: String) -> bool:
	if not SKILLS.has(skill_id): return false
	if skill_id in GameManager.skills_unlocked: return true
	
	var data = SKILLS[skill_id]
	
	# Check Requirements
	for req in data["req"]:
		if not req in GameManager.skills_unlocked:
			print("Requirement not met: ", req)
			return false
			
	# Check Cost
	if GameManager.skill_points >= data["cost"]:
		GameManager.skill_points -= data["cost"]
		GameManager.skills_unlocked.append(skill_id)
		emit_signal("skill_unlocked", skill_id)
		_apply_skill_effects(skill_id)
		return true
	
	emit_signal("insufficient_points")
	return false

func _apply_skill_effects(skill_id: String):
	match skill_id:
		"heavy_swing":
			GameManager.attack_power *= 1.2
		"mana_regen":
			# Logic handled in Player.gd via global flag
			pass
