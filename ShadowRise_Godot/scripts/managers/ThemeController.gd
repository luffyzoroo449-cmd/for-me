## ThemeController.gd
## Manages global "Full Color Themes" for the game world.
## Switches lighting, fog, parallax modulation, and music in one call.

extends Node

enum WorldTheme { FOREST, LAVA, SHADOW_REALM, FROZEN_WASTE, ANCIENT_CITY }

@export var current_theme: WorldTheme = WorldTheme.FOREST

# --- Theme Definitions (Full Palette) ---
const THEME_DATA = {
	WorldTheme.FOREST: {
		"modulate": Color(0.9, 1.0, 0.9),
		"fog_color": Color(0.1, 0.15, 0.1, 1),
		"ambient_light": Color(0.2, 0.3, 0.2, 1),
		"particles": "res://assets/particles/leaves.tres",
		"music_mood": "calm"
	},
	WorldTheme.LAVA: {
		"modulate": Color(1.2, 0.8, 0.6),
		"fog_color": Color(0.2, 0.05, 0.0, 1),
		"ambient_light": Color(0.4, 0.1, 0.0, 1),
		"particles": "res://assets/particles/embers.tres",
		"music_mood": "intense"
	},
	WorldTheme.SHADOW_REALM: {
		"modulate": Color(0.4, 0.3, 0.7),
		"fog_color": Color(0.05, 0.0, 0.1, 1),
		"ambient_light": Color(0.1, 0.05, 0.2, 1),
		"particles": "res://assets/particles/void_wisps.tres",
		"music_mood": "suspense"
	},
	WorldTheme.FROZEN_WASTE: {
		"modulate": Color(0.8, 0.9, 1.2),
		"fog_color": Color(0.8, 0.85, 1.0, 1),
		"ambient_light": Color(0.3, 0.4, 0.6, 1),
		"particles": "res://assets/particles/snow.tres",
		"music_mood": "mystery"
	}
}

func apply_theme(theme: WorldTheme, transition_speed: float = 2.0):
	current_theme = theme
	var data = THEME_DATA[theme]
	
	# 1. Transition World Environment (Fog & Ambient)
	var world_env = get_tree().get_first_node_in_group("world_env")
	if world_env:
		var env = world_env.environment
		var tween = create_tween().set_parallel(true)
		tween.tween_property(env, "fog_light_color", data["fog_color"], transition_speed)
		tween.tween_property(env, "adjustment_brightness", data["modulate"].v, transition_speed)

	# 2. Transition Global Modualte (CanvasModulate)
	var canv_mod = get_tree().get_first_node_in_group("canvas_modulate")
	if canv_mod:
		var tween = create_tween()
		tween.tween_property(canv_mod, "color", data["modulate"], transition_speed)

	# 3. Transition Music
	if SoundManager:
		SoundManager.transition_to(data["music_mood"])

	# 4. Notify Particles
	get_tree().call_group("weather_particles", "change_template", data["particles"])
