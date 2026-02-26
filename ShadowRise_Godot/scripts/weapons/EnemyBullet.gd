## EnemyBullet.gd
## Attach to: Area2D node "EnemyBullet"
## Scene structure:
##   Area2D (EnemyBullet.gd)
##   ├── Sprite2D (red orb)
##   ├── CollisionShape2D (CircleShape2D)
##   └── VisibleOnScreenNotifier2D

extends Area2D

var velocity: Vector2 = Vector2.ZERO
var damage: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func setup(vel: Vector2, dmg: int) -> void:
	velocity = vel
	damage = dmg
	
	# Set layers: enemy_bullet layer = 5
	collision_layer = 16  # bit 5
	collision_mask  = 2   # bit 2 = player layer
	
	body_entered.connect(_on_hit)

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _on_hit(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
