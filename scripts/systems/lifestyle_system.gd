extends Node

# Lifestyle system for idle D&D gameplay
# Handles lifestyle expenses, living standards, and social status

class_name LifestyleSystem

signal lifestyle_changed(character: Character, old_lifestyle: String, new_lifestyle: String)
signal lifestyle_expense_paid(character: Character, lifestyle: String, cost: int)
signal lifestyle_benefit_gained(character: Character, benefit: String, description: String)
signal lifestyle_penalty_applied(character: Character, penalty: String, description: String)

# Dynamic lifestyle system - all data loaded from YAML
# Lifestyle levels are now dynamic strings instead of enums
# Lifestyle benefits and penalties are now dynamic dictionaries

# Dynamic lifestyle data structure loaded from YAML
class Lifestyle:
	var id: String
	var name: String
	var daily_cost: float
	var description: String
	var benefits: Array[String] = []
	var penalties: Array[String] = []
	var profession_modifiers: Dictionary = {}
	var social_status: String = ""
	var typical_locations: Array[String] = []
	var typical_activities: Array[String] = []
	var reputation_effects: Dictionary = {} # Effects on faction reputation

	func _init(lifestyle_data: Dictionary):
		id = lifestyle_data.get("id", "")
		name = lifestyle_data.get("name", "")
		daily_cost = lifestyle_data.get("daily_cost", 0.0)
		description = lifestyle_data.get("description", "")
		benefits = lifestyle_data.get("benefits", [])
		penalties = lifestyle_data.get("penalties", [])
		profession_modifiers = lifestyle_data.get("profession_modifiers", {})

var lifestyles: Dictionary = {} # lifestyle_id -> Lifestyle
var lifestyle_benefits: Dictionary = {} # benefit_id -> benefit_data
var lifestyle_penalties: Dictionary = {} # penalty_id -> penalty_data
var character_lifestyles: Dictionary = {} # character_id -> lifestyle_id
var lifestyle_expenses: Dictionary = {} # character_id -> expense_data

func _init():
	setup_lifestyles()

func setup_lifestyles():
	"""Initialize all lifestyle levels with their data from YAML"""
	load_lifestyle_data()




func set_character_lifestyle(character: Character, lifestyle_id: String) -> bool:
	"""Set a character's lifestyle level"""
	var old_lifestyle = character_lifestyles.get(character.name, "POOR")

	# Check if character can afford the lifestyle
	var lifestyle = lifestyles.get(lifestyle_id)
	if lifestyle == null or not can_afford_lifestyle(character, lifestyle):
		return false

	character_lifestyles[character.name] = lifestyle_id

	# Apply lifestyle benefits and penalties
	apply_lifestyle_effects(character, lifestyle_id)

	lifestyle_changed.emit(character, old_lifestyle, lifestyle_id)
	return true

func can_afford_lifestyle(character: Character, lifestyle: Lifestyle) -> bool:
	"""Check if character can afford a lifestyle"""
	# Convert gold to copper pieces for comparison
	var character_copper = character.gold * 100
	return character_copper >= lifestyle.daily_cost

func pay_lifestyle_expenses(character: Character) -> bool:
	"""Pay daily lifestyle expenses for a character"""
	var lifestyle_id = character_lifestyles.get(character.name, "POOR") # TODO remove hardcoded value?
	var lifestyle = lifestyles.get(lifestyle_id)

	# Convert daily cost from copper to gold
	var daily_cost_gold = lifestyle.daily_cost / 100

	if not character.spend_gold(daily_cost_gold):
		# Character can't afford lifestyle, downgrade to poor
		set_character_lifestyle(character, "POOR")
		return false

	# Track expenses
	if not lifestyle_expenses.has(character.name):
		lifestyle_expenses[character.name] = {"total_spent": 0, "days_maintained": 0}

	lifestyle_expenses[character.name]["total_spent"] += daily_cost_gold
	lifestyle_expenses[character.name]["days_maintained"] += 1

	lifestyle_expense_paid.emit(character, lifestyle_id, daily_cost_gold)
	return true

func apply_lifestyle_effects(character: Character, lifestyle_id: String) -> void:
	"""Apply the effects of a lifestyle to a character"""
	var lifestyle = lifestyles.get(lifestyle_id)
	if lifestyle == null:
		return

	# Apply benefits
	for benefit in lifestyle.benefits:
		apply_lifestyle_benefit(character, benefit)

	# Apply penalties
	for penalty in lifestyle.penalties:
		apply_lifestyle_penalty(character, penalty)

	# Apply reputation effects
	for faction in lifestyle.reputation_effects.keys():
		var reputation_change = lifestyle.reputation_effects[faction]
		if not character.faction_reputation.has(faction):
			character.faction_reputation[faction] = 0
		character.faction_reputation[faction] += reputation_change

func apply_lifestyle_benefit(character: Character, benefit_id: String) -> void:
	"""Apply a specific lifestyle benefit to a character"""
	var benefit_data = lifestyle_benefits.get(benefit_id, {})
	if benefit_data.is_empty():
		return

	var _benefit_name = benefit_data.get("name", benefit_id)
	var benefit_description = benefit_data.get("description", "")
	lifestyle_benefit_gained.emit(character, benefit_id, benefit_description)

func apply_lifestyle_penalty(character: Character, penalty_id: String) -> void:
	"""Apply a specific lifestyle penalty to a character"""
	var penalty_data = lifestyle_penalties.get(penalty_id, {})
	if penalty_data.is_empty():
		return

	var _penalty_name = penalty_data.get("name", penalty_id)
	var penalty_description = penalty_data.get("description", "")
	lifestyle_penalty_applied.emit(character, penalty_id, penalty_description)

func get_character_lifestyle(character: Character) -> String:
	"""Get a character's current lifestyle level"""
	return character_lifestyles.get(character.name, "POOR")

func get_lifestyle_data(lifestyle_id: String) -> Lifestyle:
	"""Get lifestyle data for a specific level"""
	return lifestyles.get(lifestyle_id, lifestyles.get("POOR"))

func get_available_lifestyles(character: Character) -> Array[String]:
	"""Get lifestyle levels available to a character based on their wealth"""
	var available: Array[String] = []

	for lifestyle_id in lifestyles.keys():
		var lifestyle = lifestyles[lifestyle_id]
		if can_afford_lifestyle(character, lifestyle):
			available.append(lifestyle_id)

	return available

func get_lifestyle_expenses(character: Character) -> Dictionary:
	"""Get lifestyle expense information for a character"""
	return lifestyle_expenses.get(character.name, {"total_spent": 0, "days_maintained": 0})

func calculate_lifestyle_sustainability(character: Character, lifestyle_id: String) -> int:
	"""Calculate how many days a character can maintain a lifestyle with current gold"""
	var lifestyle = lifestyles.get(lifestyle_id)
	if lifestyle == null:
		return 0
	var daily_cost_gold = lifestyle.daily_cost / 100

	if daily_cost_gold <= 0:
		return 999999 # Wretched lifestyle is free

	return character.gold / daily_cost_gold

func get_lifestyle_recommendations(character: Character) -> Array[String]:
	"""Get recommended lifestyle levels for a character based on their income and goals"""
	var recommendations: Array[String] = []

	# Get character's daily income (simplified)
	var daily_income = estimate_daily_income(character)

	# Recommend lifestyle based on income
	if daily_income >= 10:
		recommendations.append("ARISTOCRATIC")
	if daily_income >= 4:
		recommendations.append("WEALTHY")
	if daily_income >= 2:
		recommendations.append("COMFORTABLE")
	if daily_income >= 1:
		recommendations.append("MODEST")
	if daily_income >= 0.2:
		recommendations.append("POOR")
	if daily_income >= 0.1:
		recommendations.append("SQUALID")

	recommendations.append("WRETCHED") # Always available

	return recommendations

func estimate_daily_income(character: Character) -> float:
	"""Estimate character's daily income based on their profession and activities"""
	# This would integrate with the profession system
	# For now, return a simple estimate based on character level
	return character.level * 2.0

func get_lifestyle_benefits_summary(character: Character) -> Dictionary:
	"""Get a summary of benefits from character's current lifestyle"""
	var lifestyle_id = get_character_lifestyle(character)
	var lifestyle = get_lifestyle_data(lifestyle_id)

	var benefits_summary = {
		"id": lifestyle_id,
		"name": lifestyle.name,
		"daily_cost": lifestyle.daily_cost / 100, # Convert to gold
		"description": lifestyle.description,
		"benefits": [],
		"penalties": [],
		"profession_modifiers": lifestyle.profession_modifiers
	}

	for benefit_id in lifestyle.benefits:
		var benefit_data = lifestyle_benefits.get(benefit_id, {})
		benefits_summary["benefits"].append(benefit_data.get("name", benefit_id))

	for penalty_id in lifestyle.penalties:
		var penalty_data = lifestyle_penalties.get(penalty_id, {})
		benefits_summary["penalties"].append(penalty_data.get("name", penalty_id))

	return benefits_summary

# YAML loading functions for lifestyle system
func load_lifestyle_data() -> void:
	"""Load lifestyle data from YAML file"""
	var file_path = "res://data/lifestyles.yaml"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Error: Could not open lifestyles file: " + file_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	var lifestyle_config = parse_yaml_lifestyles(yaml_string)
	if lifestyle_config == null:
		print("Error parsing lifestyles YAML")
		return

	# Load benefits
	var benefits_data = lifestyle_config.get("benefits", [])
	for benefit_data in benefits_data:
		var benefit_id = benefit_data.get("id", "")
		if benefit_id != "":
			lifestyle_benefits[benefit_id] = benefit_data

	# Load penalties
	var penalties_data = lifestyle_config.get("penalties", [])
	for penalty_data in penalties_data:
		var penalty_id = penalty_data.get("id", "")
		if penalty_id != "":
			lifestyle_penalties[penalty_id] = penalty_data

	# Load lifestyle data
	var lifestyles_data = lifestyle_config.get("lifestyles", [])
	for lifestyle_data in lifestyles_data:
		var lifestyle_id = lifestyle_data.get("id", "")
		if lifestyle_id != "":
			var lifestyle = Lifestyle.new(lifestyle_data)
			lifestyles[lifestyle_id] = lifestyle

	print("Loaded " + str(lifestyles.size()) + " lifestyles, " + str(lifestyle_benefits.size()) + " benefits, " + str(lifestyle_penalties.size()) + " penalties")

func parse_yaml_lifestyles(yaml_string: String) -> Dictionary:
	"""Parse YAML lifestyle configuration - returns dictionary with benefits, penalties, and lifestyles"""
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

func get_indent_level(line: String) -> int:
	"""Get the indentation level of a line"""
	var indent = 0
	for i in range(line.length()):
		if line[i] == " ":
			indent += 1
		elif line[i] == "\t":
			indent += 4
		else:
			break
	return indent

func parse_value(value: String) -> Variant:
	"""Parse a YAML value string into appropriate type"""
	# Try to parse as number
	if value.is_valid_int():
		return value.to_int()
	elif value.is_valid_float():
		return value.to_float()
	# Try to parse as boolean
	elif value == "true":
		return true
	elif value == "false":
		return false
	# Try to parse as null/empty
	elif value == "null" or value == "~" or value == "":
		return null
	# Return as string
	else:
		return value

# Dynamic lifestyle system - no more enum conversions needed
