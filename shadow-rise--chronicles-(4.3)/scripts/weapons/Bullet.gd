## Bullet.gd
## Attach to: Area2D node "Bullet"
## Scene structure:
##   Area2D (Bullet.gd)
##   ├── Sprite2D (or ColorRect for fast rendering)
##   ├── CollisionShape2D (CircleShape2D)
##   └── VisibleOnScreenNotifier2D

extends Area2D

var velocity: Vector2 = Vector2.ZERO
var damage: int = 1
var max_range: float = 200.0
var bullet_color: Color = Color("#fde047")
var spawn_position: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D

func setup(vel: Vector2, dmg: int, range_px: float, color: Color, size: float) -> void:
	velocity = vel
	damage = dmg
	max_range = range_px
	bullet_color = color
	spawn_position = global_position

	# Set size and color
	if sprite:
		sprite.modulate = color
		sprite.scale = Vector2(size / 4.0, size / 4.0)

	# Set layer: bullet layer = 4
	collision_layer = 8   # bit 4
	collision_mask  = 4   # bit 3 = enemy layer

	body_entered.connect(_on_hit)
	area_entered.connect(_on_area_hit)

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

	# Cleanup when out of range
	var dist := global_position.distance_to(spawn_position)
	if dist > max_range:
		queue_free()

func _on_hit(body: Node) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		_spawn_hit_particles()
		queue_free()

func _on_area_hit(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		var enemy := area.get_parent()
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
		_spawn_hit_particles()
		queue_free()

func _spawn_hit_particles() -> void:
	get_tree().call_group("game_world", "spawn_particles", {
		"position": global_position,
		"color": Color.RED,
		"count": 8,
		"type": "hit"
	})

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
