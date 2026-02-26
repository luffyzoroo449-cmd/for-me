## NPCLogic.gd
## Manages realistic NPC behavior for Shopkeepers, Blacksmiths, and Villagers.
## Supports head-turning, random idle gestures, and emotional reactions.

extends "res://scripts/core/HighFidelityCharacter.gd"

enum NPCType { SHOPKEEPER, GUARD, BLACKSMITH, CHILD, TRAVELER }
@export var npc_type: NPCType = NPCType.SHOPKEEPER

var is_interacted: bool = false
var target_look_at: Node2D = null

func _ready() -> void:
	super._ready()
	_init_npc_style()

func _init_npc_style() -> void:
	match npc_type:
		NPCType.BLACKSMITH:
			animation_state.travel("hammering")
		NPCType.GUARD:
			animation_state.travel("injured_idle")
		_:
			animation_state.travel("idle")

func _process(delta: float) -> void:
	if not is_active: return
	
	_handle_head_tracking(delta)
	_random_blink_and_gestures(delta)

func _handle_head_tracking(delta: float) -> void:
	# Turn head toward player if they are nearby
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) < 120:
		target_look_at = player
	else:
		target_look_at = null
	
	var head_bone = skeleton.get_node_or_null("Torso/Neck/Head")
	if head_bone and target_look_at:
		var angle_to_player = (target_look_at.global_position - head_bone.global_position).angle()
		# Clamp to realistic neck limits
		var target_rot = clamp(angle_to_player, -0.6, 0.6)
		head_bone.rotation = lerp(head_bone.rotation, target_rot, delta * 3.0)

func _random_blink_and_gestures(_delta: float) -> void:
	# Procedural blinking logic can be triggered here or in AnimationPlayer
	if randf() < 0.002: # Occasional deep breath or shift weight
		animation_state.travel("shift_weight")

func react_to_story(emotion: String) -> void:
	# Focus: facial expressions (blinking, eyebrow movement)
	match emotion:
		"anger": sprite.modulate = Color(1.2, 0.8, 0.8) # Slight red flush
		"fear": animation_state.travel("cower")
		"sad": animation_state.travel("look_down")
