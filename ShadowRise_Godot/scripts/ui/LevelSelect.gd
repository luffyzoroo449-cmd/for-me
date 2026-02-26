## LevelSelect.gd
## Attach to: Control node for the level selection screen

extends Control

@onready var grid: GridContainer = $GridContainer

func _ready() -> void:
	_build_level_grid()

func _build_level_grid() -> void:
	# Clear existing buttons
	for child in grid.get_children():
		child.queue_free()
	
	# Create 100 level buttons
	for i in range(1, 101):
		var btn = Button.new()
		btn.text = str(i)
		
		# Check if level is unlocked via GameManager
		var progress = GameManager.level_progress.get(i, {"unlocked": i == 1})
		btn.disabled = not progress["unlocked"]
		
		# Show stars if any
		if progress.get("stars", 0) > 0:
			btn.text += "\n" + "⭐".repeat(progress["stars"])
		
		btn.pressed.connect(_on_level_selected.bind(i))
		grid.add_child(btn)

func _on_level_selected(level_id: int) -> void:
	# Determine world from level_id
	var world_id = ((level_id - 1) / 10) + 1
	
	# In a real game, you might have specific scene paths:
	# var path = "res://scenes/worlds/world_%d/level_%d.tscn" % [world_id, level_id]
	# For now, we transition to a generic game world that loads level data
	
	# GameManager.current_level = level_id
	get_tree().change_scene_to_file("res://scenes/GameWorld.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
