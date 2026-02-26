## EnvironmentalSystems.gd
## Manages Day/Night cycle, Wind sway, and Weather effects (Rain/Fog)

extends Node2D

@export var cycle_speed: float = 0.01 # Speed of day transition
@export var wind_strength: float = 1.0
@export var current_weather: String = "clear" # clear, rain, fog

@onready var sun_filter: CanvasModulate = $SunFilter
@onready var rain_particles: GPUParticles2D = $RainParticles
@onready var fog_layer: ParallaxLayer = $FogLayer

# Gradient representing: Night -> Dawn -> Day -> Dusk -> Night
@export var day_night_gradient: Gradient

var time: float = 0.5 # 0.0 to 1.0 (0.5 is noon)

func _process(delta: float) -> void:
	_update_day_cycle(delta)
	_update_wind_shaders()

func _update_day_cycle(delta: float) -> void:
	time = fmod(time + delta * cycle_speed, 1.0)
	if sun_filter and day_night_gradient:
		sun_filter.color = day_night_gradient.sample(time)

func _update_wind_shaders() -> void:
	# Sends a global value to all foliage shaders for synchronized swaying
	RenderingServer.global_shader_parameter_set("wind_force", wind_strength + sin(Time.get_ticks_msec() * 0.001))

func set_weather(type: String) -> void:
	current_weather = type
	var player = get_tree().get_first_node_in_group("player")
	
	match type:
		"rain":
			rain_particles.emitting = true
			_transition_fog(0.8)
			if player: player.friction = 800.0 # Make it slippery
		"fog":
			rain_particles.emitting = false
			_transition_fog(1.2)
			if player: player.friction = 1500.0 # Standard
		"clear":
			rain_particles.emitting = false
			_transition_fog(0.0)
			if player: player.friction = 1500.0

func _transition_fog(target_opacity: float) -> void:
	var tween = create_tween()
	tween.tween_property(fog_layer, "modulate:a", target_opacity, 3.0)
