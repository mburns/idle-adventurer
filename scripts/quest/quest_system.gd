extends Node

# Quest system core - coordinates quest data management, logic, and rewards
# Simplified version that delegates to specialized modules

class_name QuestSystem

# Module instances
var quest_data_manager: QuestDataManager
var quest_logic: QuestLogic
var quest_rewards: QuestRewards

# Signals
signal quest_started(quest: QuestResource)
signal quest_completed(quest: QuestResource, rewards: Dictionary)
signal quest_failed(quest: QuestResource, reason: String)
signal objective_completed(quest: QuestResource, objective: QuestObjectiveResource)
signal quest_progress(quest: QuestResource, progress: float)

func _init():
	# Initialize modules
	quest_data_manager = QuestDataManager.new()
	quest_logic = QuestLogic.new()
	quest_rewards = QuestRewards.new()

	# Connect module signals
	quest_logic.quest_started.connect(_on_quest_started)
	quest_logic.quest_completed.connect(_on_quest_completed)
	quest_logic.objective_completed.connect(_on_objective_completed)
	quest_logic.quest_progress.connect(_on_quest_progress)

func _ready():
	# Load quest data
	quest_data_manager.load_quest_data()

# Start a quest for a character
func start_quest(character: Character, quest: QuestResource) -> bool:
	"""Start a quest for a character"""
	var success = quest_logic.start_quest(character, quest)
	if success:
		quest_started.emit(quest)
	return success

# Update quest progress
func update_quest_progress(character: Character, objective_type: String, amount: int = 1) -> void:
	"""Update progress for quest objectives"""
	quest_logic.update_quest_progress(character, objective_type, amount)

# Complete a quest
func complete_quest(character: Character, quest: QuestResource) -> void:
	"""Complete a quest and give rewards"""
	quest_logic.complete_quest(character, quest)
	quest_rewards.give_quest_rewards(character, quest.rewards)
	quest_completed.emit(quest, quest.rewards)

# Get available quests for a character
func get_available_quests(character: Character) -> Array[QuestResource]:
	"""Get all available quests for a character"""
	return quest_logic.get_available_quests(character)

# Get active quests for a character
func get_active_quests(character: Character) -> Array[QuestResource]:
	"""Get all active quests for a character"""
	return quest_logic.get_active_quests(character)

# Get completed quests for a character
func get_completed_quests(character: Character) -> Array[QuestResource]:
	"""Get all completed quests for a character"""
	return quest_logic.get_completed_quests(character)

# Abandon a quest
func abandon_quest(character: Character, quest: QuestResource) -> void:
	"""Abandon an active quest"""
	quest_logic.abandon_quest(character, quest)
	quest_failed.emit(quest, "Abandoned by player")

# Check if quest is active
func is_quest_active(character: Character, quest_id: String) -> bool:
	"""Check if a quest is currently active for a character"""
	return quest_logic.is_quest_active(character, quest_id)

# Check if quest is completed
func is_quest_completed(character: Character, quest_id: String) -> bool:
	"""Check if a quest has been completed by a character"""
	return quest_logic.is_quest_completed(character, quest_id)

# Get quest template by ID
func get_quest_template(template_id: String) -> QuestResource:
	"""Get a quest template by ID"""
	return quest_data_manager.get_quest_template(template_id)

# Get all quest templates
func get_all_quest_templates() -> Dictionary:
	"""Get all quest templates"""
	return quest_data_manager.get_all_quest_templates()

# Get quest templates by type
func get_quest_templates_by_type(quest_type: String) -> Array[QuestResource]:
	"""Get quest templates filtered by type"""
	return quest_data_manager.get_quest_templates_by_type(quest_type)

# Get quest configuration
func get_quest_configuration() -> Dictionary:
	"""Get quest configuration data"""
	return quest_data_manager.get_quest_configuration()

# Get available quest types
func get_available_quest_types() -> Array[String]:
	"""Get all available quest types"""
	return quest_data_manager.get_available_quest_types()

# Search quest templates
func search_quest_templates(query: String) -> Array[QuestResource]:
	"""Search quest templates by title or description"""
	return quest_data_manager.search_quest_templates(query)

# Get quest progress percentage
func get_quest_progress(quest: QuestResource) -> float:
	"""Get overall quest progress as a percentage"""
	return quest_logic.get_quest_progress(quest)

# Reload quest data
func reload_quest_data() -> void:
	"""Reload all quest data from files"""
	quest_data_manager.reload_quest_data()

# Get quest data manager (for advanced usage)
func get_quest_data_manager() -> QuestDataManager:
	"""Get the quest data manager instance"""
	return quest_data_manager

# Get quest logic (for advanced usage)
func get_quest_logic() -> QuestLogic:
	"""Get the quest logic instance"""
	return quest_logic

# Get quest rewards (for advanced usage)
func get_quest_rewards() -> QuestRewards:
	"""Get the quest rewards instance"""
	return quest_rewards

# Signal handlers
func _on_quest_started(quest: QuestResource) -> void:
	quest_started.emit(quest)

func _on_quest_completed(quest: QuestResource, rewards: Dictionary) -> void:
	quest_completed.emit(quest, rewards)

func _on_objective_completed(quest: QuestResource, objective: QuestObjectiveResource) -> void:
	objective_completed.emit(quest, objective)

func _on_quest_progress(quest: QuestResource, progress: float) -> void:
	quest_progress.emit(quest, progress)
