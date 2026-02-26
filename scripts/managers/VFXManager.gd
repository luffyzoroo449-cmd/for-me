## VFXManager.gd
## Singleton for cinematic enhancements: Screen Shake, Hit-Stop, and Slow Motion.

extends Node

# --- Screen Shake ---
var shake_intensity: float = 0.0
var camera: Camera2D = null

func _process(_delta):
	if camera and shake_intensity > 0:
		shake_intensity = lerp(shake_intensity, 0.0, 0.1)
		camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_intensity

# --- Professional Camera Shake ---
func shake(intensity: float):
	shake_intensity = intensity
	if not camera:
		camera = get_tree().get_first_node_in_group("player_camera")

# --- Hit-Stop / Time Scale (Cinematic Feel) ---
func hit_stop(duration: float = 0.1):
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration * 0.05).timeout
	Engine.time_scale = 1.0

# --- Slow Motion (For Finishers) ---
func slow_motion(scale: float, duration: float):
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", scale, 0.2)
	await get_tree().create_timer(duration).timeout
	tween = create_tween()
	tween.tween_property(Engine, "time_scale", 1.0, 0.5)

# --- Damage Flashes ---
func flash_sprite(sprite: CanvasItem, color: Color = Color.WHITE, _duration: float = 0.1):
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", color, 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)
