## BurstParticle.gd
## Attach to: Node2D with a GPUParticles2D or CPUParticles2D child
## Replaces the JS ParticleSystem logic with native Godot particles

extends Node2D

@onready var particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	# Clean up automatically after particles finish
	if particles:
		particles.finished.connect(queue_free)

func emit(p_color: Color, p_count: int, p_type: String) -> void:
	if not particles:
		return
	
	particles.color = p_color
	particles.amount = p_count
	
	# Adjust behavior based on type
	match p_type:
		"jump":
			particles.spread = 45
			particles.initial_velocity_min = 50
			particles.initial_velocity_max = 100
		"dash":
			particles.spread = 180
			particles.initial_velocity_min = 100
			particles.initial_velocity_max = 200
		"death":
			particles.spread = 180
			particles.initial_velocity_min = 150
			particles.initial_velocity_max = 300
			particles.amount = 30
		"hit":
			particles.spread = 60
			particles.initial_velocity_min = 80
			particles.initial_velocity_max = 150
	
	particles.emitting = true
	
	# Simple timer fallback if 'finished' signal isn't used
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	queue_free()
