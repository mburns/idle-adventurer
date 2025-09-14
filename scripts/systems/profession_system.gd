extends Node

# Profession system for idle D&D gameplay
# Handles professions, income, and professional reputation

class_name ProfessionSystem

signal profession_started(character: Character, profession: Profession)
signal profession_completed(character: Character, profession: Profession, income: int)
signal profession_level_up(character: Character, profession: Profession, new_level: int)
signal professional_reputation_changed(character: Character, profession: Profession, new_reputation: int)

# Profession types
enum ProfessionType {
	ARTISAN, # Craftsmen, artisans
	MERCHANT, # Traders, shopkeepers
	SCHOLAR, # Researchers, teachers
	GUARD, # Security, law enforcement
	PRIEST, # Religious services
	ENTERTAINER, # Performers, bards
	HEALER, # Medical practitioners
	INFORMANT, # Information brokers
	ADMINISTRATOR, # Government officials
	SERVANT # Domestic workers
}

# Work quality levels
enum WorkQuality {
	POOR, # -2 to reputation, half pay
	AVERAGE, # No change, normal pay
	GOOD, # +1 to reputation, 1.2x pay
	EXCELLENT, # +2 to reputation, 1.5x pay
	MASTERPIECE # +5 to reputation, 2x pay
}

# Profession data structure
class Profession:
	var id: String
	var name: String
	var profession_type: ProfessionType
	var description: String
	var requirements: Dictionary = {} # Requirements to start
	var daily_income: int = 0 # Base daily income
	var reputation_gain: int = 0 # Base reputation gain per day
	var skill_requirements: Array[String] = [] # Required skills
	var tool_requirements: Array[String] = [] # Required tools
	var location: String = "" # Where work is performed
	var schedule: Dictionary = {} # Work schedule
	var advancement_requirements: Dictionary = {} # Requirements for advancement
	var benefits: Dictionary = {} # Professional benefits

	func _init(prof_id: String, prof_name: String, prof_type: ProfessionType):
		id = prof_id
		name = prof_name
		profession_type = prof_type

# Professional work data structure
class ProfessionalWork:
	var profession: Profession
	var character: Character
	var start_time: int = 0
	var duration_hours: int = 8
	var work_quality: WorkQuality = WorkQuality.AVERAGE
	var daily_progress: float = 0.0
	var total_reputation: int = 0
	var total_income: int = 0
	var level: int = 1
	var experience: int = 0

	func _init(prof: Profession, character_ref: Character):
		profession = prof
		character = character_ref
		start_time = int(Time.get_unix_time_from_system())

var professions: Dictionary = {} # profession_id -> Profession
var active_work: Dictionary = {} # character_id -> ProfessionalWork
var professional_reputation: Dictionary = {} # character_id -> profession_id -> reputation
var yaml_parser: YAMLParser

func _init():
	yaml_parser = YAMLParser.new()
	setup_professions()

func setup_professions():
	"""Load professions from data files"""
	load_professions_from_directory("res://data/professions/")
	print("Loaded " + str(professions.size()) + " professions")

func load_professions_from_directory(directory_path: String) -> void:
	"""Load all profession files from a directory"""
	var yaml_files = yaml_parser.get_yaml_files_in_directory(directory_path)

	for file_path in yaml_files:
		load_professions_from_file(file_path)

func load_professions_from_file(file_path: String) -> void:
	"""Load professions from a specific YAML file"""
	var profession_data = yaml_parser.parse_yaml_file(file_path)

	if profession_data.is_empty():
		print("Error: Could not load professions from " + file_path)
		return

	var professions_data = profession_data.get("professions", [])
	for prof_data in professions_data:
		var profession_id = prof_data.get("id", "")
		var profession_name = prof_data.get("name", "")
		var profession_type_str = prof_data.get("profession_type", "")

		if profession_id == "" or profession_name == "":
			continue

		# Convert string to enum
		var profession_type = ProfessionType.ARTISAN  # Default
        # TODO can this be simplified?
		match profession_type_str:
			"ARTISAN":
				profession_type = ProfessionType.ARTISAN
			"MERCHANT":
				profession_type = ProfessionType.MERCHANT
			"SCHOLAR":
				profession_type = ProfessionType.SCHOLAR
			"GUARD":
				profession_type = ProfessionType.GUARD
			"PRIEST":
				profession_type = ProfessionType.PRIEST
			"ENTERTAINER":
				profession_type = ProfessionType.ENTERTAINER
			"HEALER":
				profession_type = ProfessionType.HEALER
			"INFORMANT":
				profession_type = ProfessionType.INFORMANT
			"ADMINISTRATOR":
				profession_type = ProfessionType.ADMINISTRATOR
			"SERVANT":
				profession_type = ProfessionType.SERVANT

		var profession = Profession.new(profession_id, profession_name, profession_type)
		profession.description = prof_data.get("description", "")
		profession.requirements = prof_data.get("requirements", {})
		profession.daily_income = prof_data.get("daily_income", 0)
		profession.reputation_gain = prof_data.get("reputation_gain", 0)
		profession.skill_requirements = prof_data.get("skill_requirements", [])
		profession.tool_requirements = prof_data.get("tool_requirements", [])
		profession.location = prof_data.get("location", "")
		profession.schedule = prof_data.get("schedule", {})
		profession.advancement_requirements = prof_data.get("advancement_requirements", {})
		profession.benefits = prof_data.get("benefits", {})

		professions[profession_id] = profession

	print("Loaded " + str(professions_data.size()) + " professions from " + file_path)

func create_merchant_professions():
	"""Create merchant professions"""
	var general_merchant = Profession.new("general_merchant", "General Merchant", ProfessionType.MERCHANT)
	general_merchant.description = "Buy and sell general goods"
	general_merchant.requirements = {"charisma": 12, "gold": 50}
	general_merchant.daily_income = 10
	general_merchant.reputation_gain = 1
	general_merchant.skill_requirements = ["persuasion"]
	general_merchant.location = "market_square"
	general_merchant.schedule = {"morning": "work", "afternoon": "work", "evening": "rest"}
	general_merchant.advancement_requirements = {"level": 3, "reputation": 30}
	general_merchant.benefits = {"trade_connections": 2, "market_knowledge": true}
	professions["general_merchant"] = general_merchant

	var luxury_merchant = Profession.new("luxury_merchant", "Luxury Merchant", ProfessionType.MERCHANT)
	luxury_merchant.description = "Deal in high-end luxury goods"
	luxury_merchant.requirements = {"charisma": 16, "gold": 500}
	luxury_merchant.daily_income = 50
	luxury_merchant.reputation_gain = 5
	luxury_merchant.skill_requirements = ["persuasion", "insight"]
	luxury_merchant.location = "noble_manor"
	luxury_merchant.schedule = {"morning": "rest", "afternoon": "work", "evening": "work"}
	luxury_merchant.advancement_requirements = {"level": 8, "reputation": 100}
	luxury_merchant.benefits = {"noble_connections": 3, "luxury_access": true}
	professions["luxury_merchant"] = luxury_merchant

func create_scholar_professions():
	"""Create scholar professions"""
	var librarian = Profession.new("librarian", "Librarian", ProfessionType.SCHOLAR)
	librarian.description = "Maintain library and assist researchers"
	librarian.requirements = {"intelligence": 14, "gold": 25}
	librarian.daily_income = 8
	librarian.reputation_gain = 2
	librarian.skill_requirements = ["history", "investigation"]
	librarian.location = "library"
	librarian.schedule = {"morning": "work", "afternoon": "work", "evening": "work"}
	librarian.advancement_requirements = {"level": 4, "reputation": 40}
	librarian.benefits = {"research_access": true, "book_discount": 0.5}
	professions["librarian"] = librarian

	var researcher = Profession.new("researcher", "Researcher", ProfessionType.SCHOLAR)
	researcher.description = "Conduct research and studies"
	researcher.requirements = {"intelligence": 16, "gold": 100}
	researcher.daily_income = 20
	researcher.reputation_gain = 4
	researcher.skill_requirements = ["arcana", "history", "investigation"]
	researcher.location = "library"
	researcher.schedule = {"morning": "work", "afternoon": "work", "evening": "study"}
	researcher.advancement_requirements = {"level": 7, "reputation": 80}
	researcher.benefits = {"arcane_knowledge": true, "spell_research": true}
	professions["researcher"] = researcher

func create_guard_professions():
	"""Create guard professions"""
	var town_guard = Profession.new("town_guard", "Town Guard", ProfessionType.GUARD)
	town_guard.description = "Protect the town and maintain order"
	town_guard.requirements = {"strength": 13, "constitution": 12, "gold": 0}
	town_guard.daily_income = 12
	town_guard.reputation_gain = 3
	town_guard.skill_requirements = ["athletics", "intimidation"]
	town_guard.location = "guard_barracks"
	town_guard.schedule = {"morning": "patrol", "afternoon": "patrol", "evening": "rest"}
	town_guard.advancement_requirements = {"level": 5, "reputation": 60}
	town_guard.benefits = {"authority": true, "security_knowledge": true}
	professions["town_guard"] = town_guard

	var guard_captain = Profession.new("guard_captain", "Guard Captain", ProfessionType.GUARD)
	guard_captain.description = "Lead the town guard"
	guard_captain.requirements = {"strength": 15, "charisma": 14, "gold": 0}
	guard_captain.daily_income = 30
	guard_captain.reputation_gain = 6
	guard_captain.skill_requirements = ["athletics", "intimidation", "leadership"]
	guard_captain.location = "guard_barracks"
	guard_captain.schedule = {"morning": "administration", "afternoon": "training", "evening": "planning"}
	guard_captain.advancement_requirements = {"level": 10, "reputation": 150}
	guard_captain.benefits = {"command_authority": true, "military_connections": true}
	professions["guard_captain"] = guard_captain

func create_priest_professions():
	"""Create priest professions"""
	var priest = Profession.new("priest", "Priest", ProfessionType.PRIEST)
	priest.description = "Provide spiritual guidance and healing"
	priest.requirements = {"wisdom": 14, "charisma": 12, "gold": 0}
	priest.daily_income = 15
	priest.reputation_gain = 4
	priest.skill_requirements = ["religion", "medicine"]
	priest.location = "temple"
	priest.schedule = {"morning": "prayer", "afternoon": "service", "evening": "study"}
	priest.advancement_requirements = {"level": 6, "reputation": 70}
	priest.benefits = {"divine_favor": true, "healing_discount": 0.5}
	professions["priest"] = priest

func create_entertainer_professions():
	"""Create entertainer professions"""
	var bard = Profession.new("bard", "Bard", ProfessionType.ENTERTAINER)
	bard.description = "Entertain with music, stories, and performances"
	bard.requirements = {"charisma": 14, "dexterity": 12, "gold": 25}
	bard.daily_income = 18
	bard.reputation_gain = 3
	bard.skill_requirements = ["performance", "persuasion"]
	bard.tool_requirements = ["musical_instrument"]
	bard.location = "golden_harp"
	bard.schedule = {"morning": "practice", "afternoon": "practice", "evening": "performance"}
	bard.advancement_requirements = {"level": 5, "reputation": 50}
	bard.benefits = {"entertainment_access": true, "social_connections": 2}
	professions["bard"] = bard

func create_healer_professions():
	"""Create healer professions"""
	var healer = Profession.new("healer", "Healer", ProfessionType.HEALER)
	healer.description = "Provide medical care and healing"
	healer.requirements = {"wisdom": 14, "intelligence": 12, "gold": 50}
	healer.daily_income = 20
	healer.reputation_gain = 4
	healer.skill_requirements = ["medicine", "nature"]
	healer.tool_requirements = ["healer_kit"]
	healer.location = "temple"
	healer.schedule = {"morning": "work", "afternoon": "work", "evening": "study"}
	healer.advancement_requirements = {"level": 6, "reputation": 60}
	healer.benefits = {"medical_knowledge": true, "healing_discount": 0.3}
	professions["healer"] = healer

func create_informant_professions():
	"""Create informant professions"""
	var spy = Profession.new("spy", "Information Broker", ProfessionType.INFORMANT)
	spy.description = "Gather and sell information"
	spy.requirements = {"dexterity": 14, "intelligence": 13, "gold": 100}
	spy.daily_income = 25
	spy.reputation_gain = 2
	spy.skill_requirements = ["stealth", "investigation", "deception"]
	spy.location = "back_alley"
	spy.schedule = {"morning": "gather", "afternoon": "gather", "evening": "sell"}
	spy.advancement_requirements = {"level": 7, "reputation": 80}
	spy.benefits = {"information_network": true, "underground_connections": true}
	professions["spy"] = spy

func create_administrator_professions():
	"""Create administrator professions"""
	var clerk = Profession.new("clerk", "Town Clerk", ProfessionType.ADMINISTRATOR)
	clerk.description = "Handle administrative tasks for the town"
	clerk.requirements = {"intelligence": 13, "charisma": 12, "gold": 25}
	clerk.daily_income = 12
	clerk.reputation_gain = 2
	clerk.skill_requirements = ["investigation", "persuasion"]
	clerk.location = "town_hall"
	clerk.schedule = {"morning": "work", "afternoon": "work", "evening": "rest"}
	clerk.advancement_requirements = {"level": 4, "reputation": 40}
	clerk.benefits = {"official_access": true, "legal_knowledge": true}
	professions["clerk"] = clerk

func create_servant_professions():
	"""Create servant professions"""
	var servant = Profession.new("servant", "Domestic Servant", ProfessionType.SERVANT)
	servant.description = "Provide domestic services"
	servant.requirements = {"constitution": 12, "gold": 0}
	servant.daily_income = 5
	servant.reputation_gain = 1
	servant.skill_requirements = ["animal_handling"]
	servant.location = "noble_manor"
	servant.schedule = {"morning": "work", "afternoon": "work", "evening": "rest"}
	servant.advancement_requirements = {"level": 2, "reputation": 20}
	servant.benefits = {"noble_access": true, "service_knowledge": true}
	professions["servant"] = servant

func start_profession(character: Character, profession_id: String) -> bool:
	"""Start a profession for a character"""
	var profession = professions.get(profession_id)
	if profession == null:
		return false

	# Check if character can start this profession
	if not can_start_profession(character, profession):
		return false

	# Check if character already has a profession
	if active_work.has(character.name):
		return false # Already working

	# Create professional work
	var work = ProfessionalWork.new(profession, character)
	active_work[character.name] = work

	# Initialize professional reputation
	if not professional_reputation.has(character.name):
		professional_reputation[character.name] = {}
	professional_reputation[character.name][profession_id] = 0

	profession_started.emit(character, profession)
	return true

func can_start_profession(character: Character, profession: Profession) -> bool:
	"""Check if character can start a profession"""
	# Check ability score requirements
	for req_key in profession.requirements.keys():
		if req_key in ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]:
			var req_value = profession.requirements[req_key]
			var char_value = character.get(req_key)
			if char_value < req_value:
				return false

	# Check gold requirement
	if profession.requirements.has("gold"):
		var required_gold = profession.requirements["gold"]
		if character.gold < required_gold:
			return false

	# Check skill requirements (simplified - would need proper skill system)
	# For now, just check if character has the required skills in their proficiencies
	for skill in profession.skill_requirements:
		if not skill in character.skill_proficiencies:
			return false

	return true

func work_profession(character: Character, _hours: int = 8) -> Dictionary:
	"""Process a day of professional work"""
	var work = active_work.get(character.name)
	if work == null:
		return {"success": false, "message": "No active profession"}

	# Calculate work quality based on character stats
	var work_quality = calculate_work_quality(character, work.profession)
	work.work_quality = work_quality

	# Calculate income and reputation
	var income = calculate_income(work.profession, work_quality, work.level)
	var reputation_gain = calculate_reputation_gain(work.profession, work_quality, work.level)

	# Give rewards
	character.add_gold(income)
	work.total_income += income
	work.total_reputation += reputation_gain

	# Update professional reputation
	if not professional_reputation.has(character.name):
		professional_reputation[character.name] = {}
	if not professional_reputation[character.name].has(work.profession.id):
		professional_reputation[character.name][work.profession.id] = 0
	professional_reputation[character.name][work.profession.id] += reputation_gain

	# Add experience
	work.experience += 10 + (work_quality * 5)

	# Check for level up
	var new_level = calculate_profession_level(work.experience)
	if new_level > work.level:
		work.level = new_level
		profession_level_up.emit(character, work.profession, new_level)

	profession_completed.emit(character, work.profession, income)
	professional_reputation_changed.emit(character, work.profession, professional_reputation[character.name][work.profession.id])

	return {
		"success": true,
		"income": income,
		"reputation_gain": reputation_gain,
		"work_quality": WorkQuality.keys()[work_quality],
		"experience_gain": 10 + (work_quality * 5)
	}

func calculate_work_quality(character: Character, profession: Profession) -> WorkQuality:
	"""Calculate work quality based on character stats and profession"""
	var quality_score = 0

	# Base quality on relevant ability scores
	match profession.profession_type:
		ProfessionType.ARTISAN:
			quality_score = character.strength + character.dexterity
		ProfessionType.MERCHANT:
			quality_score = character.charisma + character.intelligence
		ProfessionType.SCHOLAR:
			quality_score = character.intelligence + character.wisdom
		ProfessionType.GUARD:
			quality_score = character.strength + character.constitution
		ProfessionType.PRIEST:
			quality_score = character.wisdom + character.charisma
		ProfessionType.ENTERTAINER:
			quality_score = character.charisma + character.dexterity
		ProfessionType.HEALER:
			quality_score = character.wisdom + character.intelligence
		ProfessionType.INFORMANT:
			quality_score = character.dexterity + character.intelligence
		ProfessionType.ADMINISTRATOR:
			quality_score = character.intelligence + character.charisma
		ProfessionType.SERVANT:
			quality_score = character.constitution + character.charisma

	# Convert to work quality
	if quality_score >= 30:
		return WorkQuality.MASTERPIECE
	elif quality_score >= 26:
		return WorkQuality.EXCELLENT
	elif quality_score >= 22:
		return WorkQuality.GOOD
	elif quality_score >= 18:
		return WorkQuality.AVERAGE
	else:
		return WorkQuality.POOR

func calculate_income(profession: Profession, work_quality: WorkQuality, level: int) -> int:
	"""Calculate income based on profession, quality, and level"""
	var base_income = profession.daily_income

	# Apply quality multiplier
	var quality_multiplier = 1.0
	match work_quality:
		WorkQuality.POOR:
			quality_multiplier = 0.5
		WorkQuality.AVERAGE:
			quality_multiplier = 1.0
		WorkQuality.GOOD:
			quality_multiplier = 1.2
		WorkQuality.EXCELLENT:
			quality_multiplier = 1.5
		WorkQuality.MASTERPIECE:
			quality_multiplier = 2.0

	# Apply level bonus
	var level_bonus = 1.0 + (level - 1) * 0.1

	return int(base_income * quality_multiplier * level_bonus)

func calculate_reputation_gain(profession: Profession, work_quality: WorkQuality, level: int) -> int:
	"""Calculate reputation gain based on profession, quality, and level"""
	var base_reputation = profession.reputation_gain

	# Apply quality modifier
	var quality_modifier = 0
	match work_quality:
		WorkQuality.POOR:
			quality_modifier = -2
		WorkQuality.AVERAGE:
			quality_modifier = 0
		WorkQuality.GOOD:
			quality_modifier = 1
		WorkQuality.EXCELLENT:
			quality_modifier = 2
		WorkQuality.MASTERPIECE:
			quality_modifier = 5

	# Apply level bonus
	var level_bonus = max(0, level - 1)

	return max(0, base_reputation + quality_modifier + level_bonus)

func calculate_profession_level(experience: int) -> int:
	"""Calculate profession level from experience"""
	# Simple linear progression: 100 XP per level
	return min(20, int(experience / 100) + 1)

func get_available_professions(character: Character) -> Array[Profession]:
	"""Get professions available to a character"""
	var available: Array[Profession] = []

	for profession in professions.values():
		if can_start_profession(character, profession):
			available.append(profession)

	return available

func get_active_profession(character: Character) -> Profession:
	"""Get character's active profession"""
	var work = active_work.get(character.name)
	if work == null:
		return null
	return work.profession

func get_professional_reputation(character: Character, profession_id: String) -> int:
	"""Get character's reputation in a specific profession"""
	if not professional_reputation.has(character.name):
		return 0
	if not professional_reputation[character.name].has(profession_id):
		return 0
	return professional_reputation[character.name][profession_id]

func quit_profession(character: Character) -> bool:
	"""Quit current profession"""
	if not active_work.has(character.name):
		return false

	active_work.erase(character.name)

	return true

func get_profession_benefits(_character: Character, profession_id: String) -> Dictionary:
	"""Get benefits available from a profession"""
	var profession = professions.get(profession_id)
	if profession == null:
		return {}

	var benefits = {}

	# Check if character has enough reputation for benefits
	for benefit_type in profession.benefits.keys():
		var benefit_value = profession.benefits[benefit_type]
		benefits[benefit_type] = benefit_value

	return benefits
