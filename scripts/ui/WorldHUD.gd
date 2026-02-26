## WorldHUD.gd
## A miniature HUD that floats above the player or enemies.
## This provides the requested "Bars above character" look.

extends Control

@onready var hp_bar: TextureProgressBar = $HPBar
@onready var mp_bar: TextureProgressBar = $MPBar

func _process(_delta: float):
	# Update values from GameManager or parent entity
	# If attached to Player:
	hp_bar.value = GameManager.hp
	hp_bar.max_value = GameManager.max_hp
	
	mp_bar.value = GameManager.mp
	mp_bar.max_value = GameManager.max_mp
	
	# Keep the HUD upright regardless of character flipping
	var parent = get_parent()
	if parent is CharacterBody2D:
		scale.x = 1.0 / parent.scale.x
