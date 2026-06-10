extends Node

# Quest data management system
# Handles loading, parsing, and managing quest data from YAML files

class_name QuestDataManager

# Quest data storage
var quest_templates: Dictionary = {} # template_id -> QuestResource
var quest_configuration: Dictionary = {}

func _init():
	pass

# Load all quest data from files
func load_quest_data() -> void:
	"""Load all quest data from resource files"""
	load_quest_configuration()
	load_quest_templates()
	print("Loaded " + str(quest_templates.size()) + " quest templates")

# Load quest configuration
func load_quest_configuration() -> void:
	"""Load quest configuration from resource file"""
	var resource_path = "res://data/quests/quest_config.tres"
	var resource = load(resource_path)
	if resource == null:
		print("Warning: Could not load quest config from " + resource_path)
		return

	var resource_data = resource.get("metadata/yaml_data")
	if resource_data == null:
		resource_data = {}
	quest_configuration = resource_data
	print("Loaded quest configuration")

# Load quest templates
func load_quest_templates() -> void:
	"""Load quest templates from resource files"""
	var dir = DirAccess.open("res://data/quests/")
	if dir == null:
		print("Error: Could not open quests directory")
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres") and file_name != "quest_config.tres":
			var file_path = "res://data/quests/" + file_name
			load_quests_from_file(file_path)

# Load quests from a specific file
func load_quests_from_file(file_path: String) -> void:
	"""Load quest templates from a specific resource file"""
	var resource = load(file_path)
	if resource == null:
		print("Error: Could not load quest resource: " + file_path)
		return

	var resource_data = resource.get("metadata/yaml_data")
	if resource_data == null or resource_data.is_empty():
		print("Error: No quest data found in: " + file_path)
		return

	# Process quest templates
	var quests = resource_data.get("quests", [])
	for quest_template_data in quests:
		var quest_template = create_quest_from_template_data(quest_template_data)
		if quest_template:
			quest_templates[quest_template.quest_id] = quest_template

	print("Loaded " + str(quests.size()) + " quests from " + file_path)

# Create quest from template data
func create_quest_from_template_data(template_data: Dictionary) -> QuestResource:
	"""Create a QuestResource object from template data"""
	var quest = QuestResource.new()
	quest.quest_id = template_data.get("id", "")
	quest.title = template_data.get("title", "")
	quest.description = template_data.get("description", "")
	quest.quest_type = template_data.get("quest_type", "general")
	quest.rewards = template_data.get("rewards", {})
	quest.requirements = template_data.get("requirements", {})
	quest.time_limit = template_data.get("time_limit", 0)
	quest.location = template_data.get("location", "")
	quest.giver_npc = template_data.get("giver", "")
	quest.prerequisite_quests = template_data.get("prerequisites", [])

	# Create objectives
	var objectives_data = template_data.get("objectives", [])
	for objective_data in objectives_data:
		var objective = QuestObjectiveResource.new()
		objective.objective_id = objective_data.get("id", "")
		objective.description = objective_data.get("description", "")
		objective.objective_type = objective_data.get("objective_type", "kill")
		objective.target = objective_data.get("target", "")
		objective.quantity = objective_data.get("quantity", objective_data.get("target_value", 1))
		objective.location = objective_data.get("location", "")
		objective.npc = objective_data.get("npc", "")
		objective.item = objective_data.get("item", "")
		objective.optional = objective_data.get("optional", false)
		objective.hidden = objective_data.get("hidden", false)
		objective.time_limit = objective_data.get("time_limit", 0)
		objective.rewards = objective_data.get("rewards", {})
		quest.objectives.append(objective)

	return quest

# Get quest template by ID
func get_quest_template(template_id: String) -> QuestResource:
	"""Get a quest template by ID"""
	return quest_templates.get(template_id, null)

# Get all quest templates
func get_all_quest_templates() -> Dictionary:
	"""Get all quest templates"""
	return quest_templates.duplicate()

# Get quest templates by type
func get_quest_templates_by_type(quest_type: String) -> Array[QuestResource]:
	"""Get quest templates filtered by type"""
	var filtered_quests: Array[QuestResource] = []
	for quest in quest_templates.values():
		if quest.quest_type == quest_type:
			filtered_quests.append(quest)
	return filtered_quests

# Get quest configuration
func get_quest_configuration() -> Dictionary:
	"""Get quest configuration data"""
	return quest_configuration.duplicate()

# Check if quest template exists
func has_quest_template(template_id: String) -> bool:
	"""Check if a quest template exists"""
	return quest_templates.has(template_id)

# Get quest template count
func get_quest_template_count() -> int:
	"""Get total number of quest templates"""
	return quest_templates.size()

# Reload quest data
func reload_quest_data() -> void:
	"""Reload all quest data from files"""
	quest_templates.clear()
	quest_configuration.clear()
	load_quest_data()

# Validate quest template data
func validate_quest_template(template_data: Dictionary) -> bool:
	"""Validate quest template data structure"""
	var required_fields = ["id", "title", "description", "quest_type"]

	for field in required_fields:
		if not template_data.has(field) or template_data[field].is_empty():
			print("Invalid quest template: missing " + field)
			return false

	return true

# Get quest types
func get_available_quest_types() -> Array[String]:
	"""Get all available quest types"""
	var quest_types: Array[String] = []
	for quest in quest_templates.values():
		if quest.quest_type not in quest_types:
			quest_types.append(quest.quest_type)
	return quest_types

# Search quest templates
func search_quest_templates(query: String) -> Array[QuestResource]:
	"""Search quest templates by title or description"""
	var results: Array[QuestResource] = []
	query = query.to_lower()

	for quest in quest_templates.values():
		if quest.title.to_lower().contains(query) or quest.description.to_lower().contains(query):
			results.append(quest)

	return results
