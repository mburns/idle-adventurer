extends Resource
class_name QuestObjectiveResource

# Quest Objective Resource for type-safe objective management
@export var objective_id: String
@export var description: String
@export var objective_type: String  # kill, collect, deliver, talk, explore, etc.
@export var target: String  # What to kill, collect, etc.
@export var quantity: int = 1
@export var completed: int = 0
@export var location: String = ""
@export var npc: String = ""
@export var item: String = ""
@export var optional: bool = false
@export var hidden: bool = false
@export var time_limit: int = 0  # 0 means no time limit
@export var rewards: Dictionary = {}

func _init():
	objective_id = ""
	description = ""
	objective_type = "kill"
	target = ""
	quantity = 1
	completed = 0
	location = ""
	npc = ""
	item = ""
	optional = false
	hidden = false
	time_limit = 0
	rewards = {}

func is_completed() -> bool:
	return completed >= quantity

func get_progress() -> float:
	if quantity <= 0:
		return 1.0
	return float(completed) / float(quantity)

func get_completion_percentage() -> int:
	return int(get_progress() * 100)

func add_progress(amount: int = 1) -> bool:
	if is_completed():
		return false
	completed = min(completed + amount, quantity)
	return is_completed()

func set_progress(amount: int) -> bool:
	completed = clamp(amount, 0, quantity)
	return is_completed()

func reset_progress() -> void:
	completed = 0

func get_remaining() -> int:
	return max(0, quantity - completed)

func get_description_with_progress() -> String:
	if hidden and not is_completed():
		return "Hidden objective"

	var desc = description
	if not is_completed():
		desc += " (" + str(completed) + "/" + str(quantity) + ")"
	else:
		desc += " (Completed)"

	return desc

func get_status_text() -> String:
	if is_completed():
		return "Completed"
	elif completed > 0:
		return "In Progress"
	else:
		return "Not Started"

func get_remaining_time() -> int:
	if time_limit <= 0:
		return -1  # No time limit
	# This would need to be calculated based on when objective was started
	return time_limit

func is_expired() -> bool:
	return time_limit > 0 and get_remaining_time() <= 0

func can_complete() -> bool:
	return not is_completed() and not is_expired()

func get_reward_summary() -> String:
	if rewards.is_empty():
		return ""

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
