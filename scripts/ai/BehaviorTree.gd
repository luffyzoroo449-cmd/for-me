## BehaviorTree.gd
## Simple Behavior Tree implementation for more complex autonomous AI.
## Use this for high-tier enemies like the Boss or Elite Commander.

class_name BehaviorTreeNode
extends Node

enum Status { RUNNING, SUCCESS, FAILURE }

func tick(_actor: Node, _blackboard: Dictionary) -> Status:
	return Status.SUCCESS

# --- COMPOSITES ---

class Selector extends BehaviorTreeNode:
	func tick(actor: Node, blackboard: Dictionary) -> Status:
		for child in get_children():
			var s = child.tick(actor, blackboard)
			if s != Status.FAILURE:
				return s
		return Status.FAILURE

class Sequence extends BehaviorTreeNode:
	func tick(actor: Node, blackboard: Dictionary) -> Status:
		for child in get_children():
			var s = child.tick(actor, blackboard)
			if s != Status.SUCCESS:
				return s
		return Status.SUCCESS

# --- LEAF NODES (Examples) ---

class ConditionNode extends BehaviorTreeNode:
	var predicate: Callable
	func tick(_actor: Node, _blackboard: Dictionary) -> Status:
		return Status.SUCCESS if predicate.call() else Status.FAILURE

class ActionNode extends BehaviorTreeNode:
	var action: Callable
	func tick(actor: Node, _blackboard: Dictionary) -> Status:
		action.call(actor)
		return Status.SUCCESS
