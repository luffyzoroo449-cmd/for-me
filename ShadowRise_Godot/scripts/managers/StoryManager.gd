## StoryManager.gd
## Manages mid-level cutscenes, camera zooms, and dialogue transitions.

extends Node

@onready var dialogue_system = $DialogueManager
@onready var camera = get_tree().get_first_node_in_group("player_camera")

func play_cutscene(scene_id: String) -> void:
	match scene_id:
		"village_flashback":
			_run_fallback_sequence()
		"victory_outro":
			_run_victory_sequence()

func _run_fallback_sequence() -> void:
	# 1. Slow down world
	Engine.time_scale = 0.5
	# 2. Zoom camera to hut
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(1.5, 1.5), 1.0)
	
	# 3. Trigger Dialogue
	dialogue_system.start_dialogue("Narrator", [
		"The Whispering Valley wasn't always so silent.",
		"Before the Shadow Commander... there was a village here."
	])
	
	await dialogue_system.dialogue_finished
	
	# 4. Reset
	Engine.time_scale = 1.0
	tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(1.0, 1.0), 1.0)
	# Unlock quest
	GameManager.set("quest_shadow_commander", true)

func _run_victory_sequence() -> void:
	# Slow motion on final hit
	Engine.time_scale = 0.2
	await get_tree().create_timer(1.0).timeout
	Engine.time_scale = 1.0
	
	# Cinematic victory particles
	get_tree().call_group("game_world", "spawn_particles", {"type": "victory", "count": 50})
	
	dialogue_system.start_dialogue("Villager", ["He is gone... the valley is free."])
