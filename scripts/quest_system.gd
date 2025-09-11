extends Node

# Comprehensive quest system for idle D&D gameplay
# Handles quests, objectives, and story progression between adventures

class_name QuestSystem

signal quest_started(quest: Quest)
signal quest_completed(quest: Quest, rewards: Dictionary)
signal quest_failed(quest: Quest, reason: String)
signal objective_completed(quest: Quest, objective: QuestObjective)
signal quest_progress(quest: Quest, progress: float)

# Quest types
enum QuestType {
	MAIN_STORY, # Main campaign storyline
	FACTION, # Faction-specific quests
	PROFESSION, # Work-related quests
	SOCIAL, # Social interaction quests
	PERSONAL, # Character development quests
	COMMUNITY # Town/community service quests
}

# Quest status
enum QuestStatus {
	AVAILABLE, # Can be started
	ACTIVE, # Currently in progress
	COMPLETED, # Finished successfully
	FAILED, # Failed or abandoned
	LOCKED # Requirements not met
}

# Objective types
enum ObjectiveType {
	COLLECT_ITEMS, # Gather specific items
	PERFORM_ACTIVITY, # Complete certain activities
	SPEND_TIME, # Spend time on specific tasks
	REACH_LEVEL, # Achieve character level
	GAIN_REPUTATION, # Build faction reputation
	SPEND_GOLD, # Spend money on specific things
	LEARN_SKILL, # Learn new skills or languages
	MAKE_CONNECTIONS # Build social connections
}

# Quest objective data structure
class QuestObjective:
	var id: String
	var description: String
	var objective_type: ObjectiveType
	var target_value: int
	var current_value: int = 0
	var completed: bool = false
	var requirements: Dictionary = {}

	func _init(obj_id: String, obj_description: String, obj_type: ObjectiveType, target: int):
		id = obj_id
		description = obj_description
		objective_type = obj_type
		target_value = target

	func is_complete() -> bool:
		return current_value >= target_value

	func get_progress() -> float:
		if target_value <= 0:
			return 1.0
		return float(current_value) / float(target_value)

# Quest data structure
class Quest:
	var id: String
	var title: String
	var description: String
	var quest_type: QuestType
	var status: QuestStatus = QuestStatus.AVAILABLE
	var objectives: Array[QuestObjective] = []
	var rewards: Dictionary = {}
	var requirements: Dictionary = {}
	var time_limit: int = 0 # Days to complete (0 = no limit)
	var started_at: int = 0
	var completed_at: int = 0
	var giver: String = "" # NPC or faction giving the quest
	var location: String = "" # Where quest takes place

	func _init(quest_id: String, quest_title: String, quest_description: String, quest_type: QuestType):
		id = quest_id
		title = quest_title
		description = quest_description
		quest_type = quest_type

	func add_objective(objective: QuestObjective) -> void:
		objectives.append(objective)

	func is_complete() -> bool:
		for objective in objectives:
			if not objective.is_complete():
				return false
		return true

	func get_progress() -> float:
		if objectives.is_empty():
			return 1.0

		var total_progress = 0.0
		for objective in objectives:
			total_progress += objective.get_progress()

		return total_progress / objectives.size()

var active_quests: Dictionary = {} # character_id -> Array[Quest]
var available_quests: Dictionary = {} # character_id -> Array[Quest]
var completed_quests: Dictionary = {} # character_id -> Array[Quest]
var quest_templates: Dictionary = {} # Template quests for generation

func _init():
	setup_quest_templates()

func setup_quest_templates():
	"""Initialize quest templates for different types"""
	create_faction_quest_templates()
	create_profession_quest_templates()
	create_social_quest_templates()
	create_personal_quest_templates()
	create_community_quest_templates()

func create_faction_quest_templates():
	"""Create faction-specific quest templates"""
	# Harper quests
	var harper_intel = Quest.new("harper_intel", "Gather Intelligence",
		"Collect information about suspicious activities in the town", QuestType.FACTION)
	harper_intel.add_objective(QuestObjective.new("spy_activity", "Spend time gathering intelligence",
		ObjectiveType.PERFORM_ACTIVITY, 3))
	harper_intel.add_objective(QuestObjective.new("make_contacts", "Build connections with informants",
		ObjectiveType.MAKE_CONNECTIONS, 2))
	harper_intel.rewards = {"harper_reputation": 10, "gold": 25, "experience": 50}
	harper_intel.giver = "Harper Agent"
	harper_intel.location = "Twilight Hall"
	quest_templates["harper_intel"] = harper_intel

	# Zhentarim quests
	var zhent_elimination = Quest.new("zhent_elimination", "Eliminate Competition",
		"Remove a rival merchant from the market", QuestType.FACTION)
	zhent_elimination.add_objective(QuestObjective.new("gather_blackmail", "Collect compromising information",
		ObjectiveType.PERFORM_ACTIVITY, 2))
	zhent_elimination.add_objective(QuestObjective.new("spend_gold", "Pay for mercenary services",
		ObjectiveType.SPEND_GOLD, 100))
	zhent_elimination.rewards = {"zhentarim_reputation": 15, "gold": 200, "experience": 75}
	zhent_elimination.giver = "Zhentarim Lieutenant"
	zhent_elimination.location = "Darkhold"
	quest_templates["zhent_elimination"] = zhent_elimination

func create_profession_quest_templates():
	"""Create profession-related quest templates"""
	# Blacksmithing quest
	var smith_commission = Quest.new("smith_commission", "Weapon Commission",
		"Create a custom weapon for a wealthy client", QuestType.PROFESSION)
	smith_commission.add_objective(QuestObjective.new("craft_weapon", "Spend time crafting the weapon",
		ObjectiveType.PERFORM_ACTIVITY, 5))
	smith_commission.add_objective(QuestObjective.new("collect_materials", "Gather rare materials",
		ObjectiveType.COLLECT_ITEMS, 3))
	smith_commission.rewards = {"gold": 150, "smith_reputation": 20, "experience": 100}
	smith_commission.giver = "Wealthy Merchant"
	smith_commission.location = "Market District"
	quest_templates["smith_commission"] = smith_commission

	# Scholar quest
	var research_task = Quest.new("research_task", "Ancient Knowledge",
		"Research ancient texts for a scholar", QuestType.PROFESSION)
	research_task.add_objective(QuestObjective.new("study_texts", "Spend time studying",
		ObjectiveType.PERFORM_ACTIVITY, 7))
	research_task.add_objective(QuestObjective.new("learn_language", "Learn an ancient language",
		ObjectiveType.LEARN_SKILL, 1))
	research_task.rewards = {"gold": 75, "scholar_reputation": 15, "experience": 80}
	research_task.giver = "Town Scholar"
	research_task.location = "Library"
	quest_templates["research_task"] = research_task

func create_social_quest_templates():
	"""Create social interaction quest templates"""
	# Party planning
	var party_quest = Quest.new("party_quest", "Noble's Party",
		"Help organize a grand party for the local nobility", QuestType.SOCIAL)
	party_quest.add_objective(QuestObjective.new("socialize", "Attend social events",
		ObjectiveType.PERFORM_ACTIVITY, 4))
	party_quest.add_objective(QuestObjective.new("spend_gold", "Contribute to party expenses",
		ObjectiveType.SPEND_GOLD, 50))
	party_quest.rewards = {"noble_reputation": 25, "gold": 100, "experience": 60}
	party_quest.giver = "Noble Host"
	party_quest.location = "Noble Manor"
	quest_templates["party_quest"] = party_quest

func create_personal_quest_templates():
	"""Create personal development quest templates"""
	# Skill mastery
	var skill_mastery = Quest.new("skill_mastery", "Master Craftsman",
		"Reach mastery level in your chosen craft", QuestType.PERSONAL)
	skill_mastery.add_objective(QuestObjective.new("reach_level", "Achieve level 10",
		ObjectiveType.REACH_LEVEL, 10))
	skill_mastery.add_objective(QuestObjective.new("practice_craft", "Spend time practicing your craft",
		ObjectiveType.PERFORM_ACTIVITY, 20))
	skill_mastery.rewards = {"gold": 500, "master_craftsman_title": true, "experience": 200}
	skill_mastery.giver = "Self"
	skill_mastery.location = "Your Workshop"
	quest_templates["skill_mastery"] = skill_mastery

func create_community_quest_templates():
	"""Create community service quest templates"""
	# Town defense
	var town_defense = Quest.new("town_defense", "Town Watch",
		"Help improve the town's defenses", QuestType.COMMUNITY)
	town_defense.add_objective(QuestObjective.new("patrol", "Spend time on patrol duty",
		ObjectiveType.PERFORM_ACTIVITY, 10))
	town_defense.add_objective(QuestObjective.new("train_guards", "Train local guards",
		ObjectiveType.PERFORM_ACTIVITY, 5))
	town_defense.rewards = {"town_reputation": 30, "gold": 80, "experience": 120}
	town_defense.giver = "Town Captain"
	town_defense.location = "Town Hall"
	quest_templates["town_defense"] = town_defense

func generate_available_quests(character: Character) -> Array[Quest]:
	"""Generate quests available to a character based on their level, faction reputation, etc."""
	var available: Array[Quest] = []

	# Check faction reputation for faction quests
	for faction_name in character.faction_reputation.keys():
		var reputation = character.faction_reputation[faction_name]
		if reputation >= 20: # Friendly reputation
			match faction_name:
				"Harpers":
					available.append(create_quest_from_template("harper_intel", character))
				"Zhentarim":
					available.append(create_quest_from_template("zhent_elimination", character))

	# Check character level for profession quests
	if character.level >= 5:
		available.append(create_quest_from_template("smith_commission", character))

	if character.level >= 3:
		available.append(create_quest_from_template("research_task", character))

	# Check charisma for social quests
	if character.charisma >= 14:
		available.append(create_quest_from_template("party_quest", character))

	# Personal quests based on character progression
	if character.level >= 8:
		available.append(create_quest_from_template("skill_mastery", character))

	# Community quests (always available)
	available.append(create_quest_from_template("town_defense", character))

	return available

func create_quest_from_template(template_id: String, _character: Character) -> Quest:
	"""Create a quest instance from a template"""
	var template = quest_templates.get(template_id)
	if template == null:
		return null

	# Create a copy of the template
	var quest = Quest.new(template.id, template.title, template.description, template.quest_type)
	quest.giver = template.giver
	quest.location = template.location
	quest.rewards = template.rewards.duplicate()

	# Copy objectives
	for template_obj in template.objectives:
		var objective = QuestObjective.new(template_obj.id, template_obj.description,
			template_obj.objective_type, template_obj.target_value)
		objective.requirements = template_obj.requirements.duplicate()
		quest.add_objective(objective)

	return quest

func start_quest(character: Character, quest: Quest) -> bool:
	"""Start a quest for a character"""
	if not can_start_quest(character, quest):
		return false

	quest.status = QuestStatus.ACTIVE
	quest.started_at = Time.get_unix_time_from_system()

	if not active_quests.has(character.name):
		active_quests[character.name] = []
	active_quests[character.name].append(quest)

	quest_started.emit(quest)
	return true

func can_start_quest(character: Character, quest: Quest) -> bool:
	"""Check if a character can start a quest"""
	# Check if already active
	if active_quests.has(character.name):
		for active_quest in active_quests[character.name]:
			if active_quest.id == quest.id:
				return false

	# Check requirements
	for req_key in quest.requirements.keys():
		var req_value = quest.requirements[req_key]
		var char_value = character.get(req_key)
		if char_value < req_value:
			return false

	return true

func update_quest_progress(character: Character, objective_type: ObjectiveType, amount: int = 1) -> void:
	"""Update progress on quest objectives"""
	if not active_quests.has(character.name):
		return

	for quest in active_quests[character.name]:
		for objective in quest.objectives:
			if objective.objective_type == objective_type and not objective.completed:
				objective.current_value += amount
				if objective.is_complete():
					objective_completed.emit(quest, objective)

				quest_progress.emit(quest, quest.get_progress())

				# Check if quest is complete
				if quest.is_complete():
					complete_quest(character, quest)

func complete_quest(character: Character, quest: Quest) -> void:
	"""Complete a quest and give rewards"""
	quest.status = QuestStatus.COMPLETED
	quest.completed_at = Time.get_unix_time_from_system()

	# Give rewards
	for reward_type in quest.rewards.keys():
		var reward_amount = quest.rewards[reward_type]
		give_quest_reward(character, reward_type, reward_amount)

	# Move quest to completed
	if not completed_quests.has(character.name):
		completed_quests[character.name] = []
	completed_quests[character.name].append(quest)

	# Remove from active
	if active_quests.has(character.name):
		active_quests[character.name].erase(quest)

	quest_completed.emit(quest, quest.rewards)

func give_quest_reward(character: Character, reward_type: String, amount: int) -> void:
	"""Give a specific type of reward to a character"""
	match reward_type:
		"gold":
			character.add_gold(amount)
		"experience":
			character.add_experience(amount)
		"harper_reputation", "zhentarim_reputation", "noble_reputation", "town_reputation", "smith_reputation", "scholar_reputation":
			var faction_name = reward_type.replace("_reputation", "")
			if faction_name == "harper":
				faction_name = "Harpers"
			elif faction_name == "zhentarim":
				faction_name = "Zhentarim"
			elif faction_name == "noble":
				faction_name = "Lord's Alliance"
			elif faction_name == "town":
				faction_name = "Town"
			elif faction_name == "smith":
				faction_name = "Smith's Guild"
			elif faction_name == "scholar":
				faction_name = "Scholar's Guild"

			if not character.faction_reputation.has(faction_name):
				character.faction_reputation[faction_name] = 0
			character.faction_reputation[faction_name] += amount

func get_active_quests(character: Character) -> Array[Quest]:
	"""Get all active quests for a character"""
	return active_quests.get(character.name, [])

func get_available_quests(character: Character) -> Array[Quest]:
	"""Get all available quests for a character"""
	return generate_available_quests(character)

func get_completed_quests(character: Character) -> Array[Quest]:
	"""Get all completed quests for a character"""
	return completed_quests.get(character.name, [])

func abandon_quest(character: Character, quest: Quest) -> void:
	"""Abandon a quest (mark as failed)"""
	quest.status = QuestStatus.FAILED

	if active_quests.has(character.name):
		active_quests[character.name].erase(quest)

	quest_failed.emit(quest, "Abandoned by player")
