## CrumblingPlatform.gd
## Attach to: StaticBody2D
## Falls away after the player stands on it for a short time

extends StaticBody2D

@export var crumble_time: float = 0.8
@export var respawn_time: float = 2.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $DetectArea # Detection area on top of platform

var is_crumbling: bool = false

func _ready() -> void:
	if area:
		area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not is_crumbling:
		is_crumbling = true
		_start_crumble_sequence()

func _start_crumble_sequence() -> void:
	# Shake effect
	var tween = create_tween()
	for i in range(5):
		tween.tween_property(sprite, "position", Vector2(randf_range(-2, 2), 0), 0.05)
		tween.tween_property(sprite, "position", Vector2.ZERO, 0.05)
	
	await get_tree().create_timer(crumble_time).timeout
	
	# Disappear
	sprite.visible = false
	collision.set_deferred("disabled", true)
	
	# Respawn
	await get_tree().create_timer(respawn_time).timeout
	sprite.visible = true
	collision.set_deferred("disabled", false)
	is_crumbling = false
