## Pickup.gd
## Attach to: Area2D node "Pickup"
## Supports: "coin" | "gem"

extends Area2D

@export_enum("coin", "gem") var type: String = "coin"
@export var value: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Set layers: pickup layer = 6
	collision_layer = 32  # bit 6
	collision_mask  = 2   # bit 2 = player layer
	
	body_entered.connect(_on_body_entered)
	
	if sprite:
		sprite.play(type)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if type == "coin":
			body.collect_coin(value)
		else:
			body.collect_gem(value)
		
		_spawn_pickup_effect()
		queue_free()

func _spawn_pickup_effect() -> void:
	var color = Color("#fbbf24") if type == "coin" else Color("#818cf8")
	get_tree().call_group("game_world", "spawn_particles", {
		"position": global_position,
		"color": color,
		"count": 10,
		"type": "pickup"
	})
