## EffectsManager.gd
## Manages global visual atmosphere: Color Grading, Vignette, and HDR Glow transitions.
## Works in tandem with WorldEnvironment to provide a "Steam/Console" cinematic look.

extends Node

@onready var world_env: WorldEnvironment = get_tree().get_first_node_in_group("world_env")

# Preset Colors for different World ID's
const ATMOSPHERES = {
	"forest": {
		"tint": Color(0.9, 1.0, 0.9), # Slightly Green
		"glow": 1.2,
		"brightness": 1.0
	},
	"lava": {
		"tint": Color(1.2, 0.9, 0.8), # Warm/Orange
		"glow": 2.5,
		"brightness": 1.1
	},
	"shadow": {
		"tint": Color(0.7, 0.7, 1.1), # Deep Blue/Purple
		"glow": 1.5,
		"brightness": 0.8
	},
	"village": {
		"tint": Color(1.0, 1.0, 0.9), # Warm Sunlight
		"glow": 0.8,
		"brightness": 1.0
	}
}

func transition_to_atmosphere(zone_id: String, duration: float = 2.0):
	if not world_env or not ATMOSPHERES.has(zone_id): return
	
	var data = ATMOSPHERES[zone_id]
	var tween = create_tween().set_parallel(true)
	
	# Transitioning Global Modulate (Color Grading)
	var canvas_mod: CanvasModulate = get_tree().get_first_node_in_group("canvas_modulate")
	if canvas_mod:
		tween.tween_property(canvas_mod, "color", data["tint"], duration)
	
	# Adjusting HDR Glow
	var env = world_env.environment
	tween.tween_property(env, "glow_intensity", data["glow"], duration)
	
	# Adjusting Exposure/Brightness
	tween.tween_property(env, "tonemap_exposure", data["brightness"], duration)

func trigger_vignette_pulse(color: Color, speed: float = 0.5):
	var vignette = get_tree().get_first_node_in_group("vignette_rect")
	if vignette:
		var t = create_tween()
		t.tween_property(vignette, "modulate", color, speed)
		t.tween_property(vignette, "modulate", Color(1, 1, 1, 0), speed)
