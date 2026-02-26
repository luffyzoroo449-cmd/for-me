## ObjectPool.gd
## High-performance pool for recurring entities (Enemies, Bullets, Particles).

extends Node

@export var pool_size: int = 15
@export var enemy_scene: PackedScene

var _pool: Array = []

func _ready():
	for i in range(pool_size):
		var obj = enemy_scene.instantiate()
		obj.visible = false
		obj.set_process(false)
		obj.set_physics_process(false)
		add_child(obj)
		_pool.append(obj)

func get_enemy(pos: Vector2) -> Node:
	for obj in _pool:
		if not obj.visible:
			obj.global_position = pos
			obj.visible = true
			obj.set_process(true)
			obj.set_physics_process(true)
			return obj
	return null # No available slots

func return_enemy(obj: Node):
	obj.visible = false
	obj.set_process(false)
	obj.set_physics_process(false)
	obj.global_position = Vector2(-9999, -9999) # Send off map
