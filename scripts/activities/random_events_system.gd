extends Node

# Random events system for idle D&D gameplay
# Handles random encounters, events, and dynamic content

class_name RandomEventsSystem

signal random_event_triggered(event: RandomEvent, character: Character)
signal event_resolved(event: RandomEvent, character: Character, outcome: String)
signal event_choice_made(event: RandomEvent, character: Character, choice: String)

# Dynamic random events system - all data loaded from YAML
# Event types, outcomes, and rarity levels are now dynamic strings instead of enums

# Dynamic random event data structure
class RandomEvent:
	var id: String
	var name: String
	var event_type: String
	var rarity: String
	var description: String
	var choices: Array[Dictionary] = [] # Available choices
	var requirements: Dictionary = {} # Requirements to trigger
	var consequences: Dictionary = {} # Possible consequences
	var duration_hours: int = 1 # How long the event lasts
	var cooldown_days: int = 0 # Days before event can trigger again

	func _init(event_data: Dictionary):
		id = event_data.get("id", "")
		name = event_data.get("name", "")
		event_type = event_data.get("event_type", "")
		rarity = event_data.get("rarity", "COMMON")
		description = event_data.get("description", "")
		choices = event_data.get("choices", [])
		requirements = event_data.get("requirements", {})
		consequences = event_data.get("consequences", {})
		duration_hours = event_data.get("duration_hours", 1)
		cooldown_days = event_data.get("cooldown_days", 0)

# Dynamic event choice data structure
class EventChoice:
	var id: String
	var description: String
	var requirements: Dictionary = {}
	var consequences: Dictionary = {}
	var skill_check: Dictionary = {} # Skill check information
	var difficulty: int = 10 # DC for skill check

	func _init(choice_data: Dictionary):
		id = choice_data.get("id", "")
		description = choice_data.get("description", "")
		requirements = choice_data.get("requirements", {})
		consequences = choice_data.get("consequences", {})
		skill_check = choice_data.get("skill_check", {})
		difficulty = skill_check.get("difficulty", 10)

var events: Dictionary = {} # event_id -> RandomEvent
var event_history: Dictionary = {} # character_id -> Array[event_data]
var active_events: Dictionary = {} # character_id -> RandomEvent
var event_cooldowns: Dictionary = {} # character_id -> event_id -> cooldown_end_time

# YAML parser instance
var yaml_parser: YAMLParser

# Dynamic event system data
var event_types: Dictionary = {} # event_type_id -> event_type_data
var event_outcomes: Dictionary = {} # outcome_id -> outcome_data
var event_rarities: Dictionary = {} # rarity_id -> rarity_data
var event_categories: Dictionary = {} # category_id -> category_data

func _init():
	setup_event_system()

func setup_event_system():
	"""Initialize the event system with resource data"""
	load_event_configuration()
	load_event_data()
	print("Random Events System initialized with " + str(events.size()) + " events")

# Event templates are now loaded dynamically from YAML files
# Removed hardcoded event creation functions

func trigger_random_event(character: Character) -> RandomEvent:
	"""Trigger a random event for a character"""
	var available_events = get_available_events(character)
	if available_events.is_empty():
		return null

	# Weight events by rarity
	var weighted_events = []
	for event in available_events:
		var weight = get_event_weight(event.rarity)
		for i in range(weight):
			weighted_events.append(event)

	# Select random event
	var selected_event = weighted_events[randi() % weighted_events.size()]

	# Set cooldown
	if not event_cooldowns.has(character.name):
		event_cooldowns[character.name] = {}
	event_cooldowns[character.name][selected_event.id] = Time.get_unix_time_from_system() + (selected_event.cooldown_days * 24 * 60 * 60)

	# Add to active events
	active_events[character.name] = selected_event

	random_event_triggered.emit(selected_event, character)
	return selected_event

func get_available_events(character: Character) -> Array[RandomEvent]:
	"""Get events available to a character"""
	var available: Array[RandomEvent] = []

	for event in events.values():
		if can_trigger_event(character, event):
			available.append(event)

	return available

func can_trigger_event(character: Character, event: RandomEvent) -> bool:
	"""Check if an event can be triggered for a character"""
	# Check if event is on cooldown
	if event_cooldowns.has(character.name) and event_cooldowns[character.name].has(event.id):
		var cooldown_end = event_cooldowns[character.name][event.id]
		if Time.get_unix_time_from_system() < cooldown_end:
			return false

	# Check requirements
	for req_key in event.requirements.keys():
		var req_value = event.requirements[req_key]
		var char_value = character.get(req_key)
		if char_value < req_value:
			return false

	return true

func get_event_weight(rarity: String) -> int:
	"""Get weight for event selection based on rarity"""
	var rarity_data = event_rarities.get(rarity, {})
	return rarity_data.get("weight", 1)

func make_event_choice(character: Character, event: RandomEvent, choice_id: String) -> String:
	"""Make a choice for a random event"""
	var choice_data = null
	for choice in event.choices:
		if choice["id"] == choice_id:
			choice_data = choice
			break

	if choice_data == null:
		return "FAILURE"

	# Perform skill check if required
	var skill_check_result = 0
	if choice_data["skill_check"] != "":
		skill_check_result = perform_skill_check(character, choice_data["skill_check"], choice_data["difficulty"])

	# Apply consequences
	var consequences = event.consequences.get(choice_id, {})
	var outcome = apply_event_consequences(character, consequences, skill_check_result)

	# Remove from active events
	if active_events.has(character.name):
		active_events.erase(character.name)

	event_choice_made.emit(event, character, choice_id)
	event_resolved.emit(event, character, outcome)

	return outcome

func perform_skill_check(character: Character, skill: String, difficulty: int) -> int:
	"""Perform a skill check for an event"""
	# Simplified skill check - would integrate with proper skill system
	var ability_score = 10
	match skill:
		"athletics":
			ability_score = character.strength
		"persuasion":
			ability_score = character.charisma
		"insight":
			ability_score = character.wisdom
		"investigation":
			ability_score = character.intelligence
		"stealth":
			ability_score = character.dexterity
		"survival":
			ability_score = character.wisdom
		"constitution":
			ability_score = character.constitution
		"performance":
			ability_score = character.charisma

	var roll = randi() % 20 + 1
	var total = roll + character.get_ability_modifier(ability_score)

	if total >= difficulty:
		return total - difficulty # Success margin
	else:
		return - (difficulty - total) # Failure margin

func apply_event_consequences(character: Character, consequences: Dictionary, skill_check_result: int) -> String:
	"""Apply consequences of an event choice"""
	var outcome = "NEUTRAL"

	for consequence_type in consequences.keys():
		var amount = consequences[consequence_type]

		# Modify amount based on skill check result
		if skill_check_result > 0:
			amount = int(amount * (1.0 + skill_check_result * 0.1))
		elif skill_check_result < 0:
			amount = int(amount * (1.0 + skill_check_result * 0.1))

		# Apply consequence
		match consequence_type:
			"gold":
				if amount > 0:
					character.add_gold(amount)
					outcome = "SUCCESS"
				else:
					character.spend_gold(-amount)
					outcome = "FAILURE"
			"hit_points":
				character.hit_points = max(0, character.hit_points + amount)
				if amount < 0:
					outcome = "FAILURE"
			"charisma_exp", "constitution_exp", "investigation_exp", "combat_exp":
				var exp_type = consequence_type.replace("_exp", "_experience")
				character.set(exp_type, character.get(exp_type) + amount)
				outcome = "SUCCESS"
			"town_reputation", "noble_reputation", "guard_reputation", "merchant_reputation", "craft_reputation":
				var faction_name = consequence_type.replace("_reputation", "")
				if faction_name == "town":
					faction_name = "Town"
				elif faction_name == "noble":
					faction_name = "Lord's Alliance"
				elif faction_name == "guard":
					faction_name = "Town Guard"
				elif faction_name == "merchant":
					faction_name = "Merchant Guild"
				elif faction_name == "craft":
					faction_name = "Craftsman Guild"

				if not character.faction_reputation.has(faction_name):
					character.faction_reputation[faction_name] = 0
				character.faction_reputation[faction_name] += amount
				outcome = "SUCCESS"
			"social_connections", "political_connections", "mystical_knowledge", "political_knowledge", "adventure_hook", "guild_membership":
				if not character.has_method("add_" + consequence_type):
					character.set(consequence_type, character.get(consequence_type) + amount)
				outcome = "SUCCESS"
			"inventory":
				# Would integrate with inventory system
				pass

	return outcome

func get_active_event(character: Character) -> RandomEvent:
	"""Get character's active event"""
	return active_events.get(character.name, null)

func get_event_history(character: Character) -> Array:
	"""Get character's event history"""
	return event_history.get(character.name, [])

# YAML loading functions for random events system
func load_event_configuration() -> void:
	"""Load event types, outcomes, and rarity levels from resources"""
	var resource_path = "res://data/events/event_types.tres"
	var resource = load(resource_path)
	if resource == null:
		print("Error: Could not load event types from " + resource_path)
		return

	var event_config = resource.get("metadata/yaml_data")
	if event_config == null:
		event_config = {}
	if event_config.is_empty():
		print("Error: No event configuration data found")
		return

	# Load event types
	var event_types_data = event_config.get("event_types", [])
	for event_type_data in event_types_data:
		var event_type_id = event_type_data.get("id", "")
		if event_type_id != "":
			event_types[event_type_id] = event_type_data

	# Load event outcomes
	var event_outcomes_data = event_config.get("event_outcomes", [])
	for event_outcome_data in event_outcomes_data:
		var outcome_id = event_outcome_data.get("id", "")
		if outcome_id != "":
			event_outcomes[outcome_id] = event_outcome_data

	# Load event rarities
	var event_rarities_data = event_config.get("event_rarities", [])
	for event_rarity_data in event_rarities_data:
		var rarity_id = event_rarity_data.get("id", "")
		if rarity_id != "":
			event_rarities[rarity_id] = event_rarity_data

	# Load event categories
	var event_categories_data = event_config.get("event_categories", {})
	for category_id in event_categories_data.keys():
		event_categories[category_id] = event_categories_data[category_id]

	print("Loaded " + str(event_types.size()) + " event types, " + str(event_outcomes.size()) + " outcomes, " + str(event_rarities.size()) + " rarities")

func load_event_data() -> void:
	"""Load event data from resource files"""
	var events_dir = "res://data/events/"
	var dir = DirAccess.open(events_dir)

	if dir == null:
		print("Error: Could not open events directory: " + events_dir)
		return

	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres") and file_name != "event_types.tres":
			var file_path = events_dir + file_name
			load_events_from_file(file_path)

func load_events_from_file(file_path: String) -> void:
	"""Load events from a specific resource file"""
	var resource = load(file_path)
	if resource == null:
		print("Error: Could not load event resource: " + file_path)
		return

	var event_data = resource.get("metadata/yaml_data")
	if event_data == null:
		event_data = {}
	if event_data.is_empty():
		print("Error: No event data found in: " + file_path)
		return

	var events_data = event_data.get("events", [])
	for event_info in events_data:
		var event_id = event_info.get("id", "")
		if event_id != "":
			var event = RandomEvent.new(event_info)
			events[event_id] = event

	print("Loaded " + str(events_data.size()) + " events from " + file_path)

# Custom YAML parsing function removed - now using unified YAMLParser
func parse_yaml_event_config_removed(yaml_string: String) -> Dictionary:
	"""Parse YAML event configuration - DEPRECATED: Use YAMLParser instead"""
	# This function is kept for reference but should not be used
	# Use yaml_parser.parse_yaml_string(yaml_string) instead
	return {}

func parse_yaml_events_removed(yaml_string: String) -> Dictionary:
	"""Parse YAML event data"""
	var lines = yaml_string.split("\n")
	var result = {}
	var current_section = ""
	var current_array = []
	var current_object = {}
	var in_object = false
	var object_key = ""
	var in_multiline = false
	var indent_level = 0

	for line in lines:
		line = line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue

		var line_indent = get_indent_level(line)

		# Handle top-level sections
		if line_indent == 0 and ":" in line and not line.begins_with("-"):
			# Save previous section if exists
			if current_section != "" and current_array.size() > 0:
				result[current_section] = current_array

			var parts = line.split(":", 1)
			current_section = parts[0].strip_edges()
			current_array = []
			continue

		# Handle array items within sections
		if line.begins_with("- ") and line_indent == 0:
			# Save previous object if exists
			if in_object and current_object.size() > 0:
				current_array.append(current_object)

			# Start new object
			current_object = {}
			in_object = true
			continue
		elif line.begins_with("-") and line_indent > 0:
			# Handle nested array items
			var item = line.substr(1).strip_edges()
			if not current_object.has(object_key):
				current_object[object_key] = []
			current_object[object_key].append(parse_value(item))
		elif ":" in line and line_indent > 0:
			# Handle key-value pairs within objects
			if in_multiline and object_key != "":
				current_object[object_key] = current_object.get(object_key, "").strip_edges()
				in_multiline = false

			var parts = line.split(":", 1)
			object_key = parts[0].strip_edges()
			var value = parts[1].strip_edges()

			if value.is_empty():
				in_multiline = true
				current_object[object_key] = ""
			else:
				current_object[object_key] = parse_value(value)
		elif in_multiline and line_indent > indent_level:
			# Continue multiline value
			current_object[object_key] += "\n" + line

	# Add last object and section
	if in_object and current_object.size() > 0:
		current_array.append(current_object)
	if current_section != "" and current_array.size() > 0:
		result[current_section] = current_array

	return result

# Helper functions removed - now using unified YAMLParser
# These functions are no longer needed as YAMLParser handles all parsing
