## SkinManager.gd
## Premium Character Customization. Manages Player "Skins" and "Full Color" themes.
## Allows for dynamic armor tinting and particle-trailing based on selected theme.

extends Node

# --- Premium Palette ---
const SKIN_COLORS = {
	"standard": Color(1, 1, 1, 1),
	"golden_warrior": Color(1.0, 0.85, 0.2, 1), # High-end Gold
	"shadow_stalker": Color(0.4, 0.2, 0.6, 1), # Glowing Purple
	"lava_knight": Color(1.2, 0.5, 0.2, 1),    # Fiery Orange (HDR)
	"frost_guard": Color(0.5, 0.7, 1.2, 1)      # Glowing Cyan
}

func apply_skin(skin_id: String):
	if not SKIN_COLORS.has(skin_id): return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	
	var sprite = player.get_node("Visuals/MainSprite")
	var color = SKIN_COLORS[skin_id]
	
	# Smooth color transition
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", color, 0.5)
	
	# Optional: Enable specific particle trails based on skin
	_update_skin_particles(player, skin_id)

func _update_skin_particles(player, skin_id):
	var trail = player.get_node_or_null("Visuals/SkinParticles")
	if not trail: return
	
	match skin_id:
		"golden_warrior":
			trail.modulate = Color(1, 1, 0, 0.5)
			trail.emitting = true
		"shadow_stalker":
			trail.modulate = Color(0.5, 0, 1, 0.5)
			trail.emitting = true
		_:
			trail.emitting = false
