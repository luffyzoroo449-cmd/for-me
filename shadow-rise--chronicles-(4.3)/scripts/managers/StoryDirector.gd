## StoryDirector.gd
## Manages cinematic cutscenes and moral decisions.

extends Node

@onready var dialogue_ui = $DialogueManager

func trigger_event(event_id: String):
	match event_id:
		"meeting_commander":
			_handle_commander_choice()
		"companion_rescue":
			_handle_rescue_outcome()

func _handle_commander_choice():
	var lines = ["Do you surrender and join the Shadow, or perish?"]
	var choices = ["I surrender (Dark Path)", "I will fight (Light Path)"]
	
	dialogue_ui.start_dialogue("Shadow Commander", lines, choices)
	
	# Wait for response
	var idx = await dialogue_ui.choice_made
	if idx == 0: # Surrender
		GameManager.update_reputation(-20)
		_trigger_betrayal_chance()
	else:
		GameManager.update_reputation(10)
		_trigger_mid_level_boss_fight()

func _trigger_betrayal_chance():
	# If reputation is too low, companion might betray the player
	if GameManager.reputation < -50:
		get_tree().call_group("companion", "set_state", "betrayal")
		dialogue_ui.start_dialogue("Companion", ["I cannot follow a monster..."])
