## CompanionAI.gd
## A non-combative or assistive companion that follows the player smoothly.

extends CharacterBody2D

@export var follow_threshold: float = 60.0
@export var speed_mult: float = 1.1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var player: CharacterBody2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if not player: return
	
	var dist = global_position.distance_to(player.global_position)
	if dist > follow_threshold:
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * player.move_speed * speed_mult
		move_and_slide()
		
		sprite.flip_h = velocity.x < 0
		sprite.play("move")
	else:
		velocity = Vector2.ZERO
		sprite.play("idle")

# Help the player by finding secrets
func find_secret(secret_pos: Vector2) -> void:
	# Move to secret, wait, then comeback
	pass
