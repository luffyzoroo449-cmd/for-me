## ReputationManager.gd
## Manages Player Morality (Karma) and its world impacts (NPC pricing, guard hostility).

extends Node

signal reputation_changed(new_val)

# World Impact Constants
const HERO_THRESHOLD = 50
const OUTLAW_THRESHOLD = -50

func adjust_reputation(amount: int):
	GameManager.reputation += amount
	_check_thresholds()
	emit_signal("reputation_changed", GameManager.reputation)

func _check_thresholds():
	if GameManager.reputation > HERO_THRESHOLD:
		print("You are a Living Legend. NPCs offer 20% discount.")
	elif GameManager.reputation < OUTLAW_THRESHOLD:
		print("You are a Marked Outlaw. Bounty hunters will now spawn.")

# Interaction Logic
func get_shop_price_mult() -> float:
	if GameManager.reputation >= HERO_THRESHOLD: return 0.8
	if GameManager.reputation <= OUTLAW_THRESHOLD: return 1.5
	return 1.0

func is_guard_hostile() -> bool:
	return GameManager.reputation <= OUTLAW_THRESHOLD
