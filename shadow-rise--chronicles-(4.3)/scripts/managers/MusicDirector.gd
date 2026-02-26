## MusicDirector.gd
## Crossfades between "Calm" and "Combat" layers based on nearby enemies.

extends Node

@onready var calm_layer: AudioStreamPlayer = $CalmLayer
@onready var combat_layer: AudioStreamPlayer = $CombatLayer

@export var search_radius: float = 400.0
var intensity: float = 0.0 # 0 to 1

func _process(delta: float) -> void:
	_calculate_intensity()
	_update_layer_volumes(delta)

func _calculate_intensity() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var player = get_tree().get_first_node_in_group("player")
	
	if not player: return
	
	var enemies_nearby = 0
	for enemy in enemies:
		if enemy.global_position.distance_to(player.global_position) < search_radius:
			enemies_nearby += 1
	
	# Mapping intensity: 0 enemies = 0, 3+ enemies = 1
	var target = clamp(enemies_nearby / 3.0, 0.0, 1.0)
	intensity = lerp(intensity, target, 0.05)

func _update_layer_volumes(_delta: float) -> void:
	# Convert 0-1 range to Decibels (0 to -80)
	var combat_db = linear_to_db(intensity)
	var calm_db = linear_to_db(1.0 - (intensity * 0.5)) # Stay slightly audible
	
	combat_layer.volume_db = combat_db
	calm_layer.volume_db = calm_db
