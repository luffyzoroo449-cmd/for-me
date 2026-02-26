## ShadowStalker.gd
## Extends EnemyBase
## Mimics the player's movement history with a delay

extends "res://scripts/enemies/EnemyBase.gd"

@export var follow_delay_frames: int = 30
var position_history: Array = []

func _ready() -> void:
	super._ready()
	enemy_type = "shadow_stalker"
	# Shadow stalkers are often ghost-like
	sprite.modulate.a = 0.6

func _run_state(delta: float) -> void:
	if state == State.DEAD:
		return
	
	if not player:
		_do_patrol()
		return

	# Record player position
	position_history.append(player.global_position)
	
	# Only start moving after delay is reached
	if position_history.size() > follow_delay_frames:
		var target_pos = position_history.pop_front()
		
		# Move toward recorded position
		var move_dir = (target_pos - global_position).normalized()
		velocity = move_dir * move_speed * 1.5
		
		is_facing_right = velocity.x > 0
		sprite.flip_h = not is_facing_right
	else:
		velocity = Vector2.ZERO

func _update_animation() -> void:
	if state == State.DEAD:
		return
	if velocity.length() > 10:
		sprite.play("walk")
	else:
		sprite.play("idle")
