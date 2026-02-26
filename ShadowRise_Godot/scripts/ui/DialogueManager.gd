## DialogueManager.gd
## Advanced Dialogue system with choices and emotion-based response

extends Control

signal dialogue_finished
signal choice_made(index)

@onready var text_label: RichTextLabel = $Panel/Text
@onready var name_label: Label = $Panel/Name
@onready var choice_container: VBoxContainer = $Panel/Choices

var dialogue_queue: Array = []
var is_active: bool = false

func start_dialogue(npc_name: String, lines: Array, choices: Array = []) -> void:
	name_label.text = npc_name
	dialogue_queue = lines
	is_active = true
	visible = true
	_show_next_line(choices)

func _show_next_line(choices: Array) -> void:
	if dialogue_queue.is_empty():
		if choices.is_empty():
			_finish()
		else:
			_show_choices(choices)
		return

	var line = dialogue_queue.pop_front()
	text_label.text = line
	
	# Realistic typewriter effect using VisibleRatio
	text_label.visible_ratio = 0
	var tween = create_tween()
	tween.tween_property(text_label, "visible_ratio", 1.0, line.length() * 0.03)

func _show_choices(choices: Array) -> void:
	# Clear old choice buttons
	for child in choice_container.get_children():
		child.queue_free()
	
	for i in range(choices.size()):
		var btn = Button.new()
		btn.text = choices[i]
		btn.pressed.connect(_on_choice_selected.bind(i))
		choice_container.add_child(btn)

func _on_choice_selected(idx: int) -> void:
	emit_signal("choice_made", idx)
	_finish()

func _finish() -> void:
	is_active = false
	visible = false
	emit_signal("dialogue_finished")
