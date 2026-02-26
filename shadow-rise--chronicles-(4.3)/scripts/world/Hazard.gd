## Hazard.gd
## Attach to: Area2D node
## Used for: Spikes, Falling Rocks, Laser Beams, etc.

extends Area2D

@export var damage: int = 1
@export var push_force: float = 300.0

func _ready() -> void:
	# Set layers: trigger layer = 7
	collision_layer = 64  # bit 7
	collision_mask  = 2   # bit 2 = player layer
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
			# Apply a bit of knockback
			var dir = (body.global_position - global_position).normalized()
			body.velocity = dir * push_force
