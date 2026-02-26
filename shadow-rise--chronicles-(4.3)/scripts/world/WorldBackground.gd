## WorldBackground.gd
## Attach to: ParallaxBackground node
## 
## Handles theme-based coloring for backgrounds across 10 worlds

extends ParallaxBackground

@export var world_id: int = 1

# From WorldConfig.js (mapped to Godot Colors)
const WORLD_THEMES := {
	1: Color("#2d5a1b"), # Forest
	2: Color("#451a03"), # Cave
	3: Color("#1e3a8a"), # Snow
	4: Color("#78350f"), # Desert
	5: Color("#7f1d1d"), # Lava
	6: Color("#0ea5e9"), # Sky
	7: Color("#374151"), # Factory
	8: Color("#4c1d95"), # Haunted
	9: Color("#164e63"), # Cyber
	10: Color("#000000") # Shadow Kingdom
}

@onready var bg_rect: CanvasLayer = $BackgroundLayer # A CanvasLayer with a TextureRect

func _ready() -> void:
	# Update color based on world theme
	if WORLD_THEMES.has(world_id):
		var theme_color = WORLD_THEMES[world_id]
		# You could modulate background layers or apply a tint to the whole scene
		# For example, if you have a CanvasModulate node:
		# get_node_or_null("CanvasModulate").color = theme_color.lerp(Color.WHITE, 0.5)
		pass

func _process(_delta: float) -> void:
	# Parallax nodes handle motion automatically based on layer scale
	pass
