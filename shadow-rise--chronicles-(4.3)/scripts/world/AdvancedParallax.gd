## AdvancedParallax.gd
## Cinematic Parallax with automatic cloud rolling and lighting-layer blending.
## Enhances the 6000px+ long maps with atmospheric depth.

extends ParallaxBackground

@export var cloud_speed: float = 10.0
@export var cloud_layer_path: NodePath
var cloud_layer: ParallaxLayer

func _ready():
	if cloud_layer_path:
		cloud_layer = get_node(cloud_layer_path)

func _process(delta: float):
	# Constant rolling for the atmosphere
	if cloud_layer:
		cloud_layer.motion_offset.x += cloud_speed * delta
	
	# Adjust modulation based on Time of Day (if integrated with EnvironmentalSystems)
	var tint = Color.WHITE
	if $"/root/EnvironmentalSystems":
		tint = $"/root/EnvironmentalSystems".get_current_sky_tint()
	
	# Smoothly modulate all layers
	for child in get_children():
		if child is ParallaxLayer:
			child.modulate = lerp(child.modulate, tint, 0.01)

func set_fog_density(density: float):
	# Blur the background layers to simulate heavy mist/fog
	for child in get_children():
		if child is ParallaxLayer:
			var sprite = child.get_child(0)
			if sprite and sprite is Sprite2D and sprite.material:
				sprite.material.set_shader_parameter("blur", density)
