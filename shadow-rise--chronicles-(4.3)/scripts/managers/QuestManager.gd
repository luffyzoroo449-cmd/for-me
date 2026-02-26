## QuestManager.gd
## Manages Player Missions, Reputation-based branching, and Choice-tracking.

extends Node

enum QuestState { NOT_STARTED, ACTIVE, COMPLETED, FAILED }

# --- Quest Data Structure ---
var quests = {
	"village_hero": {
		"title": "Protector of the Valley",
		"state": QuestState.NOT_STARTED,
		"objectives": {"kill_scouts": 5, "find_healer": 1},
		"reputation_reward": 20
	},
	"shadow_pact": {
		"title": "A Dark Alliance",
		"state": QuestState.NOT_STARTED,
		"objectives": {"betray_guard": 1},
		"reputation_reward": -50
	}
}

# --- Signals ---
signal quest_updated(quest_id)
signal objective_completed(quest_id, objective)

func start_quest(quest_id: String):
	if quests.has(quest_id):
		quests[quest_id].state = QuestState.ACTIVE
		emit_signal("quest_updated", quest_id)

func update_objective(quest_id: String, objective: String, amount: int = 1):
	if quests.has(quest_id) and quests[quest_id].state == QuestState.ACTIVE:
		var q = quests[quest_id]
		if q.objectives.has(objective):
			q.objectives[objective] -= amount
			if q.objectives[objective] <= 0:
				q.objectives[objective] = 0
				emit_signal("objective_completed", quest_id, objective)
			
			_check_quest_completion(quest_id)

func _check_quest_completion(quest_id: String):
	var q = quests[quest_id]
	var finished = true
	for obj in q.objectives:
		if q.objectives[obj] > 0:
			finished = false
			break
	
	if finished:
		q.state = QuestState.COMPLETED
		GameManager.update_reputation(q.reputation_reward)
		GameManager.add_xp(500)
		emit_signal("quest_updated", quest_id)
