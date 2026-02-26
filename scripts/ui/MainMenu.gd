## MainMenu.gd
## Attach to: Control node for the main menu scene

extends Control

func _ready() -> void:
	# Hide mouse cursor if on mobile/touch
	if OS.get_name() in ["Android", "iOS"]:
		pass # Godot handles touch globally
	
	# Play menu music
	# AudioManager.play_music("menu_theme")

func _on_play_pressed() -> void:
	# Go to level select or continue last level
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")

func _on_settings_pressed() -> void:
	# Show settings overlay
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
