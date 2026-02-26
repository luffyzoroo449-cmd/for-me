## ExitPortal.gd
## Attach to: Area2D

extends Area2D

func _ready() -> void:
	# Set layers
	collision_layer = 64
	collision_mask = 2
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# Trigger level completion in GameWorld
		get_tree().call_group("game_world", "on_exit_reached")
