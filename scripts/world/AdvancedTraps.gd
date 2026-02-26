## AdvancedTraps.gd
## Unified system for Lava, Poision, Crushing, and Invisible Spikes.

extends Area2D

enum TrapType { LAVA, POISON_GAS, SPIKES, SWINGING_BLADE, CRUSHER }
@export var type: TrapType = TrapType.SPIKES
@export var damage_per_second: float = 10.0
@export var is_triggered_only: bool = false # For hidden traps

var is_active := true

func _ready():
	if is_triggered_only:
		visible = false
		monitoring = false

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		_activate_trap(body)

func _activate_trap(player: Node):
	match type:
		TrapType.SPIKES:
			player.take_damage(25)
			_spawn_blood_fx(player.global_position)
		TrapType.SWINGING_BLADE:
			player.take_damage(40)
			# Apply heavy knockback
			var dir = (player.global_position - global_position).normalized()
			player.velocity = dir * 600.0
		TrapType.CRUSHER:
			player.take_damage(100) # Instant kill

func _physics_process(delta: float):
	if not monitoring: return
	
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			if type == TrapType.LAVA or type == TrapType.POISON_GAS:
				body.take_damage(damage_per_second * delta)
				_spawn_burn_fx(body.global_position)

func trigger_hidden():
	visible = true
	monitoring = true
	$AnimationPlayer.play("reveal")
