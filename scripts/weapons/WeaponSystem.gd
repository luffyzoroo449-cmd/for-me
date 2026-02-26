## WeaponSystem.gd
## Manages weapon logic, element effects, and durability depletion.
## Attach to Player's Weapon child node.

extends Node2D

@export var current_weapon: WeaponData

# --- Signals ---
signal weapon_broken
signal weapon_upgraded(new_level)

func _ready():
	if current_weapon:
		_apply_visuals()

func use_weapon():
	if not current_weapon or current_weapon.durability <= 0:
		return
		
	# Deplete durability per swing
	current_weapon.durability -= 0.5
	if current_weapon.durability <= 0:
		emit_signal("weapon_broken")
		_spawn_break_particles()

	# Return calculated damage based on engine/element
	return current_weapon.get_damage()

func get_element_color() -> Color:
	match current_weapon.element:
		WeaponData.Element.FIRE: return Color("#ef4444") # Red
		WeaponData.Element.ICE: return Color("#38bdf8") # Light Blue
		WeaponData.Element.MAGIC: return Color("#a855f7") # Purple
		_: return Color("#ffffff") # White

func upgrade_current_weapon():
	if current_weapon:
		current_weapon.upgrade()
		emit_signal("weapon_upgraded", current_weapon.upgrade_level)

func _apply_visuals():
	# Modulate weapon sprite or trail based on element
	$WeaponSprite.modulate = get_element_color()
	
	# Enable element-specific particles
	if current_weapon.element == WeaponData.Element.FIRE:
		$FireParticles.emitting = true
	elif current_weapon.element == WeaponData.Element.ICE:
		$IceParticles.emitting = true

func _spawn_break_particles():
	get_tree().call_group("game_world", "spawn_particles", {
		"position": global_position,
		"color": Color.GRAY,
		"count": 15,
		"type": "shatter"
	})
