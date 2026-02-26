## InventoryManager.gd
## Manages Player items, weapon inventory, and consumables.
## Persists through GameManager and SaveSystem.

extends Node

# --- Item Structure ---
class Item:
	var id: String
	var name: String
	var type: String # "weapon", "consumable", "material"
	var quantity: int = 1
	var icon: Texture2D

var items: Array[Item] = []
var max_slots: int = 24

# --- Signals ---
signal inventory_changed
signal item_added(item)
signal item_removed(item)

func add_item(id: String, name: String, type: String, qty: int = 1):
	# Check if stackable
	for item in items:
		if item.id == id and type != "weapon":
			item.quantity += qty
			emit_signal("inventory_changed")
			return true
			
	if items.size() < max_slots:
		var new_item = Item.new()
		new_item.id = id
		new_item.name = name
		new_item.type = type
		new_item.quantity = qty
		items.append(new_item)
		emit_signal("item_added", new_item)
		emit_signal("inventory_changed")
		return true
		
	return false

func remove_item(id: String, qty: int = 1):
	for i in range(items.size()):
		if items[i].id == id:
			items[i].quantity -= qty
			if items[i].quantity <= 0:
				var removed = items.pop_at(i)
				emit_signal("item_removed", removed)
			emit_signal("inventory_changed")
			return true
	return false

func has_item(id: String) -> bool:
	for item in items:
		if item.id == id: return true
	return false
