## InteriorSystem.gd
## Manages transitions between "Exterior" world and "Interior" spaces (huts, shops).
## 
## Use an Area2D at doorways to trigger the transition.

extends Node2D

@export var interior_node_path: NodePath
@export var exterior_node_path: NodePath

@onready var interior = get_node(interior_node_path)
@onready var exterior = get_node(exterior_node_path)

func _ready() -> void:
	# Start with interior hidden
	if interior:
		interior.visible = false
		_set_node_processing(interior, false)

func enter_interior() -> void:
	var tween = create_tween()
	# Smooth fade out exterior / fade in interior
	if exterior:
		tween.parallel().tween_property(exterior, "modulate:a", 0.0, 0.4)
	if interior:
		interior.visible = true
		interior.modulate.a = 0.0
		tween.parallel().tween_property(interior, "modulate:a", 1.0, 0.4)
	
	await tween.finished
	_set_node_processing(exterior, false)
	_set_node_processing(interior, true)
	if exterior: exterior.visible = false

func exit_interior() -> void:
	var tween = create_tween()
	if interior:
		tween.parallel().tween_property(interior, "modulate:a", 0.0, 0.4)
	if exterior:
		exterior.visible = true
		exterior.modulate.a = 0.0
		tween.parallel().tween_property(exterior, "modulate:a", 1.0, 0.4)
	
	await tween.finished
	_set_node_processing(interior, false)
	_set_node_processing(exterior, true)
	if interior: interior.visible = false

func _set_node_processing(node: Node, active: bool) -> void:
	node.set_process(active)
	node.set_physics_process(active)
	# Recursive for children
	for child in node.get_children():
		_set_node_processing(child, active)
