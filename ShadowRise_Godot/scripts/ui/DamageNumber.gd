## DamageNumber.gd
## A physics-based floating text that pops up when enemies or players take damage.
## Transitions from a bright color to faded, while bouncing slightly.

extends Marker2D

@onready var label: Label = $Label

func setup(amount: float, is_critical: bool = false):
	label.text = str(floor(amount))
	
	if is_critical:
		label.add_theme_color_override("font_color", Color("#f59e0b")) # Gold for Crits
		scale = Vector2(1.5, 1.5)
	else:
		label.add_theme_color_override("font_color", Color("#ef4444")) # Red for Standard
	
	_animate()

func _animate():
	var tween = create_tween().set_parallel(true)
	
	# Initial "Physics" Bounce
	var random_x = randf_range(-40, 40)
	tween.tween_property(self, "position", position + Vector2(random_x, -60), 0.4).set_trans(Tween.TRANS_OUT).set_ease(Tween.EASE_OUT)
	
	# Fade and Fall
	tween.chain().tween_property(self, "position", position + Vector2(random_x, 20), 0.6).set_trans(Tween.TRANS_IN).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.6)
	
	await tween.finished
	queue_free()
