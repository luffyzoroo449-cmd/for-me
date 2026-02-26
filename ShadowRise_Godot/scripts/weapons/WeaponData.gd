## WeaponData.gd
## A Resource class to define weapon stats and elemental types.
## Create individual .tres files for Sword, Fire Sword, etc.

extends Resource
class_name WeaponData

enum Element { NONE, FIRE, ICE, MAGIC, PHYSICAL }

@export var weapon_name: String = "Mystic Blade"
@export var element: Element = Element.NONE
@export var base_damage: float = 15.0
@export var attack_speed: float = 1.0 # Multiplier
@export var durability: float = 100.0
@export var max_durability: float = 100.0

@export var upgrade_level: int = 0
@export_multiline var description: String = ""
@export var icon: Texture2D

func upgrade():
	upgrade_level += 1
	base_damage *= 1.2
	max_durability += 10
	durability = max_durability

func get_damage() -> float:
	# Durability penalty: logic for realistic weapon wear
	var penalty = 1.0 if durability > 20 else 0.7
	return base_damage * penalty
