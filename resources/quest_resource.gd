extends Resource
class_name QuestResource

# Quest Resource for type-safe quest management
@export var quest_id: String
@export var title: String
@export var description: String
@export var quest_type: String
@export var level: int
@export var status: String = "available"  # available, active, completed, failed
@export var rewards: Dictionary = {}
@export var objectives: Array[QuestObjectiveResource] = []
@export var requirements: Dictionary = {}
@export var time_limit: int = 0  # 0 means no time limit
@export var prerequisite_quests: Array[String] = []
@export var next_quests: Array[String] = []
@export var faction: String = ""
@export var location: String = ""
@export var giver_npc: String = ""

func _init():
	quest_id = ""
	title = ""
	description = ""
	quest_type = "fetch"
	level = 1
	status = "available"
	rewards = {}
	objectives = []
	requirements = {}
	time_limit = 0
	prerequisite_quests = []
	next_quests = []
	faction = ""
	location = ""
	giver_npc = ""

func is_available() -> bool:
	return status == "available"

func is_active() -> bool:
	return status == "active"

func is_completed() -> bool:
	return status == "completed"

func is_failed() -> bool:
	return status == "failed"

func can_start() -> bool:
	return is_available() and meets_requirements()

func meets_requirements() -> bool:
	# Override in subclasses for specific requirement checking
	return true

func start_quest() -> bool:
	if not can_start():
		return false
	status = "active"
	return true

func complete_quest() -> bool:
	if not is_active():
		return false
	status = "completed"
	return true

func fail_quest() -> bool:
	if not is_active():
		return false
	status = "failed"
	return true

func abandon_quest() -> bool:
	if not is_active():
		return false
	status = "available"
	return true

func get_progress() -> float:
	if objectives.is_empty():
		return 1.0 if is_completed() else 0.0

	var completed_objectives = 0
	for objective in objectives:
		if objective.is_completed():
			completed_objectives += 1

	return float(completed_objectives) / float(objectives.size())

func get_completion_percentage() -> int:
	return int(get_progress() * 100)

func get_remaining_time() -> int:
	if time_limit <= 0:
		return -1  # No time limit
	# This would need to be calculated based on when quest was started
	return time_limit

func get_reward_summary() -> String:
	var summary = ""
	if rewards.has("gold") and rewards["gold"] > 0:
		summary += str(rewards["gold"]) + " gold"
	if rewards.has("xp") and rewards["xp"] > 0:
		if summary != "":
			summary += ", "
		summary += str(rewards["xp"]) + " XP"
	if rewards.has("items") and rewards["items"].size() > 0:
		if summary != "":
			summary += ", "
		summary += str(rewards["items"].size()) + " items"
	return summary
