extends Node

# Quest logic system
# Handles quest progression, completion, requirements checking, and objective management

class_name QuestLogic

# Signals
signal quest_started(quest: QuestResource)
signal quest_completed(quest: QuestResource, rewards: Dictionary)
signal quest_failed(quest: QuestResource, reason: String)
signal objective_completed(quest: QuestResource, objective: QuestObjectiveResource)
signal quest_progress(quest: QuestResource, progress: float)

# Quest data manager reference
var quest_data_manager: QuestDataManager

# Character quest data storage
var character_quests: Dictionary = {} # character_name -> Array[QuestResource]

func _init():
	quest_data_manager = QuestDataManager.new()

# Generate available quests for a character
func generate_available_quests(character: Character) -> Array[QuestResource]:
	"""Generate quests available to a character based on their level and progress"""
	var available_quests: Array[QuestResource] = []
	var quest_templates = quest_data_manager.get_all_quest_templates()

	for template_id in quest_templates:
		var quest_template = quest_templates[template_id]

		# Skip if already completed
		if is_quest_completed(character, quest_template.id):
			continue

		# Skip if already active
		if is_quest_active(character, quest_template.id):
			continue

		# Check if character meets requirements
		if meets_quest_requirements(character, quest_template):
			var quest_copy = create_quest_copy(quest_template)
			available_quests.append(quest_copy)

	return available_quests

# Check if character meets quest requirements
func meets_quest_requirements(character: Character, quest: QuestResource) -> bool:
	"""Check if character meets all quest requirements"""
	var requirements = quest.requirements

	# Check level requirement
	if requirements.has("level"):
		if character.level < requirements["level"]:
			return false

	# Check gold requirement
	if requirements.has("gold"):
		if character.gold < requirements["gold"]:
			return false

	# Check item requirements
	if requirements.has("items"):
		var required_items = requirements["items"]
		if required_items is Array:
			for item in required_items:
				# This would check if character has the item
				# For now, just return true
				pass

	# Check skill requirements
	if requirements.has("skills"):
		var required_skills = requirements["skills"]
		if required_skills is Array:
			for skill in required_skills:
				if skill not in character.skill_proficiencies:
					return false

	# Check prerequisite quests
	if quest.prerequisites.size() > 0:
		for prereq_id in quest.prerequisites:
			if not is_quest_completed(character, prereq_id):
				return false

	return true

# Create a copy of a quest template
func create_quest_copy(quest_template: QuestResource) -> QuestResource:
	"""Create a copy of a quest template for a character"""
	var quest_copy = QuestResource.new()
	quest_copy.quest_id = quest_template.quest_id
	quest_copy.title = quest_template.title
	quest_copy.description = quest_template.description
	quest_copy.quest_type = quest_template.quest_type
	quest_copy.rewards = quest_template.rewards.duplicate()
	quest_copy.requirements = quest_template.requirements.duplicate()
	quest_copy.time_limit = quest_template.time_limit
	quest_copy.location = quest_template.location
	quest_copy.giver_npc = quest_template.giver_npc
	quest_copy.prerequisite_quests = quest_template.prerequisite_quests.duplicate()

	# Copy objectives
	for objective_template in quest_template.objectives:
		var objective_copy = QuestObjectiveResource.new()
		objective_copy.objective_id = objective_template.objective_id
		objective_copy.description = objective_template.description
		objective_copy.objective_type = objective_template.objective_type
		objective_copy.target = objective_template.target
		objective_copy.quantity = objective_template.quantity
		objective_copy.completed = 0  # Reset progress for new quest instance
		objective_copy.location = objective_template.location
		objective_copy.npc = objective_template.npc
		objective_copy.item = objective_template.item
		objective_copy.optional = objective_template.optional
		objective_copy.hidden = objective_template.hidden
		objective_copy.time_limit = objective_template.time_limit
		objective_copy.rewards = objective_template.rewards.duplicate()
		quest_copy.objectives.append(objective_copy)

	return quest_copy

# Start a quest for a character
func start_quest(character: Character, quest: QuestResource) -> bool:
	"""Start a quest for a character"""
	if not can_start_quest(character, quest):
		return false

	# Initialize character quest data if needed
	if not character_quests.has(character.name):
		character_quests[character.name] = []

	# Add quest to character's active quests
	quest.status = "active"
	character_quests[character.name].append(quest)

	print("Started quest: " + quest.title + " for " + character.name)
	quest_started.emit(quest)
	return true

# Check if character can start a quest
func can_start_quest(character: Character, quest: QuestResource) -> bool:
	"""Check if character can start a quest"""
	# Check if already active
	if is_quest_active(character, quest.quest_id):
		return false

	# Check if already completed
	if is_quest_completed(character, quest.quest_id):
		return false

	# Check requirements
	if not meets_quest_requirements(character, quest):
		return false

	return true

# Update quest progress
func update_quest_progress(character: Character, objective_type: String, amount: int = 1) -> void:
	"""Update progress for quest objectives of a specific type"""
	if not character_quests.has(character.name):
		return

	var active_quests = character_quests[character.name]
	for quest in active_quests:
		if quest.status != "active":
			continue

		for objective in quest.objectives:
			if objective.objective_type == objective_type and not objective.is_completed():
				objective.add_progress(amount)

				if objective.is_completed():
					print("Completed objective: " + objective.description)
					objective_completed.emit(quest, objective)

				# Emit progress signal
				var progress = get_quest_progress(quest)
				quest_progress.emit(quest, progress)

				# Check if quest is complete
				if is_quest_objectives_complete(quest):
					complete_quest(character, quest)

# Check if all quest objectives are complete
func is_quest_objectives_complete(quest: QuestResource) -> bool:
	"""Check if all objectives in a quest are complete"""
	for objective in quest.objectives:
		if not objective.is_completed():
			return false
	return true

# Complete a quest
func complete_quest(character: Character, quest: QuestResource) -> void:
	"""Complete a quest and give rewards"""
	quest.status = "completed"

	# Give rewards
	var quest_rewards = QuestRewards.new()
	quest_rewards.give_quest_rewards(character, quest.rewards)

	print("Completed quest: " + quest.title + " for " + character.name)
	quest_completed.emit(quest, quest.rewards)

# Check if quest is active
func is_quest_active(character: Character, quest_id: String) -> bool:
	"""Check if a quest is currently active for a character"""
	if not character_quests.has(character.name):
		return false

	var active_quests = character_quests[character.name]
	for quest in active_quests:
		if quest.quest_id == quest_id and quest.status == "active":
			return true

	return false

# Check if quest is completed
func is_quest_completed(character: Character, quest_id: String) -> bool:
	"""Check if a quest has been completed by a character"""
	if not character_quests.has(character.name):
		return false

	var active_quests = character_quests[character.name]
	for quest in active_quests:
		if quest.quest_id == quest_id and quest.status == "completed":
			return true

	return false

# Get active quests for a character
func get_active_quests(character: Character) -> Array[QuestResource]:
	"""Get all active quests for a character"""
	if not character_quests.has(character.name):
		return []

	var active_quests: Array[QuestResource] = []
	for quest in character_quests[character.name]:
		if quest.status == "active":
			active_quests.append(quest)

	return active_quests

# Get available quests for a character
func get_available_quests(character: Character) -> Array[QuestResource]:
	"""Get all available quests for a character"""
	return generate_available_quests(character)

# Get completed quests for a character
func get_completed_quests(character: Character) -> Array[QuestResource]:
	"""Get all completed quests for a character"""
	if not character_quests.has(character.name):
		return []

	var completed_quests: Array[QuestResource] = []
	for quest in character_quests[character.name]:
		if quest.status == "completed":
			completed_quests.append(quest)

	return completed_quests

# Abandon a quest
func abandon_quest(character: Character, quest: QuestResource) -> void:
	"""Abandon an active quest"""
	if not character_quests.has(character.name):
		return

	var active_quests = character_quests[character.name]
	var quest_index = active_quests.find(quest)
	if quest_index >= 0:
		quest.status = "available"
		active_quests.remove_at(quest_index)
		print("Abandoned quest: " + quest.title + " for " + character.name)

# Get quest progress percentage
func get_quest_progress(quest: QuestResource) -> float:
	"""Get overall quest progress as a percentage"""
	if quest.objectives.is_empty():
		return 1.0

	var total_progress = 0.0
	for objective in quest.objectives:
		total_progress += objective.get_progress()

	return total_progress / quest.objectives.size()

# Get quest data manager
func get_quest_data_manager() -> QuestDataManager:
	"""Get the quest data manager instance"""
	return quest_data_manager
