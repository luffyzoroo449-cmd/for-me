## Checkpoint.gd
## Attach to: Area2D

extends Area2D

var is_active: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Set layers
	collision_layer = 64
	collision_mask = 2
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not is_active:
		is_active = true
		if sprite:
			sprite.play("active")
		
		# SFX and particles
		get_tree().call_group("game_world", "spawn_particles", {
			"position": global_position,
			"color": Color("#4ade80"),
			"count": 15,
			"type": "checkpoint"
		})
		
		# Set this as player spawn point
		# GameManager could store this if needed for persistence within a level
