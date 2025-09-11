extends Node

# Lifestyle system for idle D&D gameplay
# Handles lifestyle expenses, living standards, and social status

class_name LifestyleSystem

signal lifestyle_changed(character: Character, old_lifestyle: LifestyleLevel, new_lifestyle: LifestyleLevel)
signal lifestyle_expense_paid(character: Character, lifestyle: LifestyleLevel, cost: int)
signal lifestyle_benefit_gained(character: Character, benefit: String, description: String)
signal lifestyle_penalty_applied(character: Character, penalty: String, description: String)

# Lifestyle levels based on D&D 5e
enum LifestyleLevel {
	WRETCHED, # Free - living in inhumane conditions
	SQUALID, # 1 sp/day - leaky stable, mud-floored hut
	POOR, # 2 sp/day - simple food, threadbare clothing
	MODEST, # 1 gp/day - clean living, older part of town
	COMFORTABLE, # 2 gp/day - nice clothing, private room
	WEALTHY, # 4 gp/day - luxury, spacious home
	ARISTOCRATIC # 10+ gp/day - life of plenty, servants
}

# Lifestyle benefits and penalties
enum LifestyleBenefit {
	SAFETY, # Protection from crime
	SOCIAL_CONNECTIONS, # Access to important people
	INFORMATION, # Gossip and news
	RESPECT, # Social standing
	COMFORT, # Physical comfort
	OPPORTUNITIES, # Business and social opportunities
	HEALTH, # Better health and healing
	EDUCATION, # Access to learning
	ENTERTAINMENT, # Recreation and fun
	STATUS # Social status and recognition
}

# Lifestyle penalty types
enum LifestylePenalty {
	CRIME_RISK, # Increased chance of theft/violence
	SOCIAL_ISOLATION, # Difficulty making connections
	HEALTH_RISK, # Disease and poor health
	RESPECT_LOSS, # Social stigma
	OPPORTUNITY_LOSS, # Missed opportunities
	COMFORT_LOSS, # Physical discomfort
	INFORMATION_LOSS, # Lack of news and gossip
	STATUS_LOSS, # Social standing decline
	EDUCATION_LOSS, # Limited learning opportunities
	ENTERTAINMENT_LOSS # Lack of recreation
}

# Lifestyle data structure
class Lifestyle:
	var level: LifestyleLevel
	var daily_cost: int # Cost in copper pieces
	var description: String
	var benefits: Array[LifestyleBenefit] = []
	var penalties: Array[LifestylePenalty] = []
	var social_status: String = ""
	var typical_locations: Array[String] = []
	var typical_activities: Array[String] = []
	var reputation_effects: Dictionary = {} # Effects on faction reputation

	func _init(lifestyle_level: LifestyleLevel):
		level = lifestyle_level

var lifestyles: Dictionary = {} # LifestyleLevel -> Lifestyle
var character_lifestyles: Dictionary = {} # character_id -> LifestyleLevel
var lifestyle_expenses: Dictionary = {} # character_id -> expense_data

func _init():
	setup_lifestyles()

func setup_lifestyles():
	"""Initialize all lifestyle levels with their data"""
	create_wretched_lifestyle()
	create_squalid_lifestyle()
	create_poor_lifestyle()
	create_modest_lifestyle()
	create_comfortable_lifestyle()
	create_wealthy_lifestyle()
	create_aristocratic_lifestyle()

func create_wretched_lifestyle():
	"""Create wretched lifestyle data"""
	var lifestyle = Lifestyle.new(LifestyleLevel.WRETCHED)
	lifestyle.daily_cost = 0 # Free
	lifestyle.description = "Living in inhumane conditions with no place to call home"
	lifestyle.penalties = [LifestylePenalty.CRIME_RISK, LifestylePenalty.HEALTH_RISK, LifestylePenalty.RESPECT_LOSS]
	lifestyle.social_status = "Outcast"
	lifestyle.typical_locations = ["streets", "abandoned_buildings", "barns"]
	lifestyle.typical_activities = ["begging", "scavenging", "hiding"]
	lifestyle.reputation_effects = {"Town": - 10, "Lord's Alliance": - 20}
	lifestyles[LifestyleLevel.WRETCHED] = lifestyle

func create_squalid_lifestyle():
	"""Create squalid lifestyle data"""
	var lifestyle = Lifestyle.new(LifestyleLevel.SQUALID)
	lifestyle.daily_cost = 10 # 1 sp = 10 cp
	lifestyle.description = "Living in a leaky stable or mud-floored hut in the worst part of town"
	lifestyle.penalties = [LifestylePenalty.CRIME_RISK, LifestylePenalty.HEALTH_RISK]
	lifestyle.benefits = [LifestyleBenefit.SAFETY] # Some protection
	lifestyle.social_status = "Desperate"
	lifestyle.typical_locations = ["slums", "boarding_houses", "stables"]
	lifestyle.typical_activities = ["manual_labor", "scavenging", "avoiding_trouble"]
	lifestyle.reputation_effects = {"Town": - 5, "Lord's Alliance": - 10}
	lifestyles[LifestyleLevel.SQUALID] = lifestyle

func create_poor_lifestyle():
	"""Create poor lifestyle data"""
	var lifestyle = Lifestyle.new(LifestyleLevel.POOR)
	lifestyle.daily_cost = 20 # 2 sp = 20 cp
	lifestyle.description = "Simple food and lodgings, threadbare clothing, unpredictable conditions"
	lifestyle.penalties = [LifestylePenalty.CRIME_RISK]
	lifestyle.benefits = [LifestyleBenefit.SAFETY, LifestyleBenefit.COMFORT]
	lifestyle.social_status = "Working Class"
	lifestyle.typical_locations = ["flophouses", "tavern_rooms", "worker_districts"]
	lifestyle.typical_activities = ["unskilled_labor", "basic_trades", "socializing"]
	lifestyle.reputation_effects = {"Town": 0, "Lord's Alliance": - 5}
	lifestyles[LifestyleLevel.POOR] = lifestyle

func create_modest_lifestyle():
	"""Create modest lifestyle data"""
	var lifestyle = Lifestyle.new(LifestyleLevel.MODEST)
	lifestyle.daily_cost = 100 # 1 gp = 100 cp
	lifestyle.description = "Clean living conditions in an older part of town, renting a room"
	lifestyle.benefits = [LifestyleBenefit.SAFETY, LifestyleBenefit.COMFORT, LifestyleBenefit.HEALTH]
	lifestyle.social_status = "Respectable"
	lifestyle.typical_locations = ["boarding_houses", "inns", "temples"]
	lifestyle.typical_activities = ["skilled_trades", "education", "community_service"]
	lifestyle.reputation_effects = {"Town": 5, "Lord's Alliance": 0}
	lifestyles[LifestyleLevel.MODEST] = lifestyle

func create_comfortable_lifestyle():
	"""Create comfortable lifestyle data"""
	var lifestyle = Lifestyle.new(LifestyleLevel.COMFORTABLE)
	lifestyle.daily_cost = 200 # 2 gp = 200 cp
	lifestyle.description = "Nice clothing, private room at a fine inn, middle-class neighborhood"
	lifestyle.benefits = [LifestyleBenefit.SAFETY, LifestyleBenefit.COMFORT, LifestyleBenefit.HEALTH, LifestyleBenefit.SOCIAL_CONNECTIONS]
	lifestyle.social_status = "Middle Class"
	lifestyle.typical_locations = ["private_rooms", "middle_class_districts", "fine_inns"]
	lifestyle.typical_activities = ["skilled_professions", "social_events", "education"]
	lifestyle.reputation_effects = {"Town": 10, "Lord's Alliance": 5}
	lifestyles[LifestyleLevel.COMFORTABLE] = lifestyle

func create_wealthy_lifestyle():
	"""Create wealthy lifestyle data"""
	var lifestyle = Lifestyle.new(LifestyleLevel.WEALTHY)
	lifestyle.daily_cost = 400 # 4 gp = 400 cp
	lifestyle.description = "Life of luxury, spacious home in a good part of town, small staff"
	lifestyle.benefits = [LifestyleBenefit.SAFETY, LifestyleBenefit.COMFORT, LifestyleBenefit.HEALTH, LifestyleBenefit.SOCIAL_CONNECTIONS, LifestyleBenefit.OPPORTUNITIES, LifestyleBenefit.RESPECT]
	lifestyle.social_status = "Wealthy"
	lifestyle.typical_locations = ["spacious_homes", "good_districts", "fine_inns"]
	lifestyle.typical_activities = ["business", "social_events", "luxury_entertainment"]
	lifestyle.reputation_effects = {"Town": 20, "Lord's Alliance": 15}
	lifestyles[LifestyleLevel.WEALTHY] = lifestyle

func create_aristocratic_lifestyle():
	"""Create aristocratic lifestyle data"""
	var lifestyle = Lifestyle.new(LifestyleLevel.ARISTOCRATIC)
	lifestyle.daily_cost = 1000 # 10 gp = 1000 cp
	lifestyle.description = "Life of plenty and comfort, townhouse in the nicest part, servants"
	lifestyle.benefits = [LifestyleBenefit.SAFETY, LifestyleBenefit.COMFORT, LifestyleBenefit.HEALTH, LifestyleBenefit.SOCIAL_CONNECTIONS, LifestyleBenefit.OPPORTUNITIES, LifestyleBenefit.RESPECT, LifestyleBenefit.STATUS, LifestyleBenefit.EDUCATION, LifestyleBenefit.ENTERTAINMENT]
	lifestyle.penalties = [LifestylePenalty.CRIME_RISK] # Attracts thieves
	lifestyle.social_status = "Noble"
	lifestyle.typical_locations = ["townhouses", "noble_districts", "finest_inns"]
	lifestyle.typical_activities = ["politics", "high_society", "luxury_entertainment"]
	lifestyle.reputation_effects = {"Town": 30, "Lord's Alliance": 25, "Noble Houses": 20}
	lifestyles[LifestyleLevel.ARISTOCRATIC] = lifestyle

func set_character_lifestyle(character: Character, lifestyle_level: LifestyleLevel) -> bool:
	"""Set a character's lifestyle level"""
	var old_lifestyle = character_lifestyles.get(character.name, LifestyleLevel.POOR)

	# Check if character can afford the lifestyle
	var lifestyle = lifestyles[lifestyle_level]
	if not can_afford_lifestyle(character, lifestyle):
		return false

	character_lifestyles[character.name] = lifestyle_level

	# Apply lifestyle benefits and penalties
	apply_lifestyle_effects(character, lifestyle_level)

	lifestyle_changed.emit(character, old_lifestyle, lifestyle_level)
	return true

func can_afford_lifestyle(character: Character, lifestyle: Lifestyle) -> bool:
	"""Check if character can afford a lifestyle"""
	# Convert gold to copper pieces for comparison
	var character_copper = character.gold * 100
	return character_copper >= lifestyle.daily_cost

func pay_lifestyle_expenses(character: Character) -> bool:
	"""Pay daily lifestyle expenses for a character"""
	var lifestyle_level = character_lifestyles.get(character.name, LifestyleLevel.POOR)
	var lifestyle = lifestyles[lifestyle_level]

	# Convert daily cost from copper to gold
	var daily_cost_gold = lifestyle.daily_cost / 100

	if not character.spend_gold(daily_cost_gold):
		# Character can't afford lifestyle, downgrade to poor
		set_character_lifestyle(character, LifestyleLevel.POOR)
		return false

	# Track expenses
	if not lifestyle_expenses.has(character.name):
		lifestyle_expenses[character.name] = {"total_spent": 0, "days_maintained": 0}

	lifestyle_expenses[character.name]["total_spent"] += daily_cost_gold
	lifestyle_expenses[character.name]["days_maintained"] += 1

	lifestyle_expense_paid.emit(character, lifestyle_level, daily_cost_gold)
	return true

func apply_lifestyle_effects(character: Character, lifestyle_level: LifestyleLevel) -> void:
	"""Apply the effects of a lifestyle to a character"""
	var lifestyle = lifestyles[lifestyle_level]

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

func apply_lifestyle_benefit(character: Character, benefit: LifestyleBenefit) -> void:
	"""Apply a specific lifestyle benefit to a character"""
	match benefit:
		LifestyleBenefit.SAFETY:
			lifestyle_benefit_gained.emit(character, "safety", "Reduced risk of crime and violence")
		LifestyleBenefit.SOCIAL_CONNECTIONS:
			lifestyle_benefit_gained.emit(character, "social_connections", "Access to important social networks")
		LifestyleBenefit.INFORMATION:
			lifestyle_benefit_gained.emit(character, "information", "Access to gossip and news")
		LifestyleBenefit.RESPECT:
			lifestyle_benefit_gained.emit(character, "respect", "Improved social standing")
		LifestyleBenefit.COMFORT:
			lifestyle_benefit_gained.emit(character, "comfort", "Better living conditions")
		LifestyleBenefit.OPPORTUNITIES:
			lifestyle_benefit_gained.emit(character, "opportunities", "Access to business and social opportunities")
		LifestyleBenefit.HEALTH:
			lifestyle_benefit_gained.emit(character, "health", "Better health and access to healing")
		LifestyleBenefit.EDUCATION:
			lifestyle_benefit_gained.emit(character, "education", "Access to learning opportunities")
		LifestyleBenefit.ENTERTAINMENT:
			lifestyle_benefit_gained.emit(character, "entertainment", "Access to recreation and entertainment")
		LifestyleBenefit.STATUS:
			lifestyle_benefit_gained.emit(character, "status", "Improved social status")

func apply_lifestyle_penalty(character: Character, penalty: LifestylePenalty) -> void:
	"""Apply a specific lifestyle penalty to a character"""
	match penalty:
		LifestylePenalty.CRIME_RISK:
			lifestyle_penalty_applied.emit(character, "crime_risk", "Increased risk of theft and violence")
		LifestylePenalty.SOCIAL_ISOLATION:
			lifestyle_penalty_applied.emit(character, "social_isolation", "Difficulty making social connections")
		LifestylePenalty.HEALTH_RISK:
			lifestyle_penalty_applied.emit(character, "health_risk", "Increased risk of disease and poor health")
		LifestylePenalty.RESPECT_LOSS:
			lifestyle_penalty_applied.emit(character, "respect_loss", "Reduced social standing")
		LifestylePenalty.OPPORTUNITY_LOSS:
			lifestyle_penalty_applied.emit(character, "opportunity_loss", "Missed business and social opportunities")
		LifestylePenalty.COMFORT_LOSS:
			lifestyle_penalty_applied.emit(character, "comfort_loss", "Poor living conditions")
		LifestylePenalty.INFORMATION_LOSS:
			lifestyle_penalty_applied.emit(character, "information_loss", "Limited access to news and gossip")
		LifestylePenalty.STATUS_LOSS:
			lifestyle_penalty_applied.emit(character, "status_loss", "Declining social status")
		LifestylePenalty.EDUCATION_LOSS:
			lifestyle_penalty_applied.emit(character, "education_loss", "Limited learning opportunities")
		LifestylePenalty.ENTERTAINMENT_LOSS:
			lifestyle_penalty_applied.emit(character, "entertainment_loss", "Lack of recreation and entertainment")

func get_character_lifestyle(character: Character) -> LifestyleLevel:
	"""Get a character's current lifestyle level"""
	return character_lifestyles.get(character.name, LifestyleLevel.POOR)

func get_lifestyle_data(lifestyle_level: LifestyleLevel) -> Lifestyle:
	"""Get lifestyle data for a specific level"""
	return lifestyles.get(lifestyle_level, lifestyles[LifestyleLevel.POOR])

func get_available_lifestyles(character: Character) -> Array[LifestyleLevel]:
	"""Get lifestyle levels available to a character based on their wealth"""
	var available: Array[LifestyleLevel] = []

	for lifestyle_level in LifestyleLevel.values():
		var lifestyle = lifestyles[lifestyle_level]
		if can_afford_lifestyle(character, lifestyle):
			available.append(lifestyle_level)

	return available

func get_lifestyle_expenses(character: Character) -> Dictionary:
	"""Get lifestyle expense information for a character"""
	return lifestyle_expenses.get(character.name, {"total_spent": 0, "days_maintained": 0})

func calculate_lifestyle_sustainability(character: Character, lifestyle_level: LifestyleLevel) -> int:
	"""Calculate how many days a character can maintain a lifestyle with current gold"""
	var lifestyle = lifestyles[lifestyle_level]
	var daily_cost_gold = lifestyle.daily_cost / 100

	if daily_cost_gold <= 0:
		return 999999 # Wretched lifestyle is free

	return character.gold / daily_cost_gold

func get_lifestyle_recommendations(character: Character) -> Array[LifestyleLevel]:
	"""Get recommended lifestyle levels for a character based on their income and goals"""
	var recommendations: Array[LifestyleLevel] = []

	# Get character's daily income (simplified)
	var daily_income = estimate_daily_income(character)

	# Recommend lifestyle based on income
	if daily_income >= 10:
		recommendations.append(LifestyleLevel.ARISTOCRATIC)
	if daily_income >= 4:
		recommendations.append(LifestyleLevel.WEALTHY)
	if daily_income >= 2:
		recommendations.append(LifestyleLevel.COMFORTABLE)
	if daily_income >= 1:
		recommendations.append(LifestyleLevel.MODEST)
	if daily_income >= 0.2:
		recommendations.append(LifestyleLevel.POOR)
	if daily_income >= 0.1:
		recommendations.append(LifestyleLevel.SQUALID)

	recommendations.append(LifestyleLevel.WRETCHED) # Always available

	return recommendations

func estimate_daily_income(character: Character) -> float:
	"""Estimate character's daily income based on their profession and activities"""
	# This would integrate with the profession system
	# For now, return a simple estimate based on character level
	return character.level * 2.0

func get_lifestyle_benefits_summary(character: Character) -> Dictionary:
	"""Get a summary of benefits from character's current lifestyle"""
	var lifestyle_level = get_character_lifestyle(character)
	var lifestyle = get_lifestyle_data(lifestyle_level)

	var benefits_summary = {
		"level": LifestyleLevel.keys()[lifestyle_level],
		"daily_cost": lifestyle.daily_cost / 100, # Convert to gold
		"social_status": lifestyle.social_status,
		"benefits": [],
		"penalties": [],
		"reputation_effects": lifestyle.reputation_effects
	}

	for benefit in lifestyle.benefits:
		benefits_summary["benefits"].append(LifestyleBenefit.keys()[benefit])

	for penalty in lifestyle.penalties:
		benefits_summary["penalties"].append(LifestylePenalty.keys()[penalty])

	return benefits_summary
