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
	"""Load lifestyle data using the resource manager"""
	var lifestyle_manager = AutoloadManager.get_lifestyle_manager()
	if lifestyle_manager == null:
		print("Error: Lifestyle manager not available")
		return

	# Copy lifestyles from resource manager to local storage
	var all_lifestyles = lifestyle_manager.get_all_lifestyles()
	for lifestyle_id in all_lifestyles:
		var lifestyle_resource = all_lifestyles[lifestyle_id]

		# Convert resource to legacy Lifestyle class
		var lifestyle_data = {
			"id": lifestyle_resource.id,
			"name": lifestyle_resource.name,
			"daily_cost": lifestyle_resource.daily_cost,
			"description": lifestyle_resource.description,
			"benefits": lifestyle_resource.benefits,
			"profession_modifiers": lifestyle_resource.profession_modifiers
		}

		var lifestyle = Lifestyle.new(lifestyle_data)
		lifestyles[lifestyle_id] = lifestyle

	# Copy benefits from resource manager
	var all_benefits = lifestyle_manager.get_all_benefits()
	for benefit_id in all_benefits:
		lifestyle_benefits[benefit_id] = all_benefits[benefit_id]

	print("Loaded " + str(lifestyles.size()) + " lifestyles, " + str(lifestyle_benefits.size()) + " benefits")

# Custom YAML parsing functions removed - now using unified YAMLParser via resource manager

# Dynamic lifestyle system - no more enum conversions needed
