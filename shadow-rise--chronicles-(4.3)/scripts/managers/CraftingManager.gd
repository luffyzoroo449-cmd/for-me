## CraftingManager.gd
## Manages weapon upgrades and material crafting for professional character progression.

extends Node

# --- Resources & Materials ---
var materials = {
	"iron_ore": 0,
	"magic_essence": 0,
	"fire_crystal": 0,
	"shadow_shard": 0
}

# --- Recipes ---
const RECIPES = {
	"iron_handle": {"iron_ore": 5},
	"fire_gem": {"fire_crystal": 10, "magic_essence": 2},
	"shadow_blade_repair": {"shadow_shard": 50, "magic_essence": 20}
}

# --- Signals ---
signal materials_updated
signal upgrade_success(weapon_name, new_level)
signal crafting_failed(reason)

func add_material(id: String, amount: int):
	if materials.has(id):
		materials[id] += amount
		emit_signal("materials_updated")

func can_craft(recipe_id: String) -> bool:
	if not RECIPES.has(recipe_id): return false
	var recipe = RECIPES[recipe_id]
	for mat in recipe:
		if materials[mat] < recipe[mat]: return false
	return true

func craft_item(recipe_id: String):
	if can_craft(recipe_id):
		var recipe = RECIPES[recipe_id]
		for mat in recipe:
			materials[mat] -= recipe[mat]
		emit_signal("materials_updated")
		# Give crafted item or trigger effect
		return true
	emit_signal("crafting_failed", "Insufficient materials")
	return false

func upgrade_weapon(weapon_data: WeaponData):
	var cost = weapon_data.upgrade_level * 10 # Scaling cost
	if materials["iron_ore"] >= cost:
		materials["iron_ore"] -= cost
		weapon_data.upgrade()
		emit_signal("upgrade_success", weapon_data.weapon_name, weapon_data.upgrade_level)
		emit_signal("materials_updated")
		return true
	return false
