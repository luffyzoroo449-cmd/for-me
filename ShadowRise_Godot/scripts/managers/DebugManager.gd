## DebugManager.gd
## Allows for instant app testing of Themes and Skins using hotkeys.

extends Node

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				ThemeController.apply_theme(ThemeController.WorldTheme.FOREST)
				print("Switched to Forest")
			KEY_2:
				ThemeController.apply_theme(ThemeController.WorldTheme.LAVA)
				print("Switched to Lava")
			KEY_3:
				ThemeController.apply_theme(ThemeController.WorldTheme.SHADOW_REALM)
				print("Switched to Shadow")
			KEY_G:
				SkinManager.apply_skin("golden_warrior")
			KEY_S:
				SkinManager.apply_skin("shadow_stalker")
			KEY_R:
				get_tree().reload_current_scene()
