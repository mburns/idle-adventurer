extends Node

# Profession system for idle D&D gameplay
# Handles professions, income, and professional reputation

class_name ProfessionSystemNew

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

	func _init(prof: Profession, char: Character):
		profession = prof
		character = char
		start_time = Time.get_unix_time_from_system()

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
		return {}

	var profession = work.profession
	var work_quality = calculate_work_quality(character, profession)
	var income = calculate_income(profession, work_quality, work.level)
	var reputation_gain = calculate_reputation_gain(profession, work_quality, work.level)

	# Update work data
	work.total_income += income
	work.total_reputation += reputation_gain
	work.experience += 1

	# Update professional reputation
	if not professional_reputation.has(character.name):
		professional_reputation[character.name] = {}
	if not professional_reputation[character.name].has(profession.id):
		professional_reputation[character.name][profession.id] = 0
	professional_reputation[character.name][profession.id] += reputation_gain

	# Check for level up
	var new_level = calculate_profession_level(work.experience)
	if new_level > work.level:
		work.level = new_level
		profession_level_up.emit(character, profession, new_level)

	# Give income to character
	character.gold += income

	profession_completed.emit(character, profession, income)
	professional_reputation_changed.emit(character, profession, professional_reputation[character.name][profession.id])

	return {
		"income": income,
		"reputation_gain": reputation_gain,
		"work_quality": work_quality,
		"level": work.level,
		"total_experience": work.experience
	}

func calculate_work_quality(character: Character, profession: Profession) -> WorkQuality:
	"""Calculate work quality based on character stats and profession"""
	var quality_score = 0

	# Base quality from relevant ability scores
	match profession.profession_type:
		ProfessionType.ARTISAN:
			quality_score += character.strength + character.dexterity
		ProfessionType.MERCHANT:
			quality_score += character.charisma + character.intelligence
		ProfessionType.SCHOLAR:
			quality_score += character.intelligence + character.wisdom
		ProfessionType.GUARD:
			quality_score += character.strength + character.constitution
		ProfessionType.PRIEST:
			quality_score += character.wisdom + character.charisma
		ProfessionType.ENTERTAINER:
			quality_score += character.charisma + character.dexterity
		ProfessionType.HEALER:
			quality_score += character.wisdom + character.intelligence
		ProfessionType.INFORMANT:
			quality_score += character.dexterity + character.intelligence
		ProfessionType.ADMINISTRATOR:
			quality_score += character.intelligence + character.charisma
		ProfessionType.SERVANT:
			quality_score += character.constitution + character.charisma

	# Add random element
	quality_score += randi_range(-5, 5)

	# Convert to quality level
	if quality_score >= 30:
		return WorkQuality.MASTERPIECE
	elif quality_score >= 25:
		return WorkQuality.EXCELLENT
	elif quality_score >= 20:
		return WorkQuality.GOOD
	elif quality_score >= 15:
		return WorkQuality.AVERAGE
	else:
		return WorkQuality.POOR

func calculate_income(profession: Profession, work_quality: WorkQuality, level: int) -> int:
	"""Calculate income based on profession, quality, and level"""
	var base_income = profession.daily_income
	var level_multiplier = 1.0 + (level - 1) * 0.1 # 10% bonus per level

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

	return int(base_income * level_multiplier * quality_multiplier)

func calculate_reputation_gain(profession: Profession, work_quality: WorkQuality, level: int) -> int:
	"""Calculate reputation gain based on profession, quality, and level"""
	var base_reputation = profession.reputation_gain
	var level_multiplier = 1.0 + (level - 1) * 0.05 # 5% bonus per level

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

	return int(base_reputation * level_multiplier) + quality_modifier

func calculate_profession_level(experience: int) -> int:
	"""Calculate profession level from experience"""
	# Simple linear progression: 100 XP per level
	return max(1, int(experience / 100) + 1)

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
	return professional_reputation[character.name].get(profession_id, 0)

func quit_profession(character: Character) -> bool:
	"""Quit current profession"""
	if not active_work.has(character.name):
		return false
	active_work.erase(character.name)
	return true

func get_profession_benefits(character: Character, profession_id: String) -> Dictionary:
	"""Get benefits available from a profession"""
	var profession = professions.get(profession_id)
	if profession == null:
		return {}

	var reputation = get_professional_reputation(character, profession_id)
	var level = 1
	if active_work.has(character.name) and active_work[character.name].profession.id == profession_id:
		level = active_work[character.name].level

	return profession.benefits.get("level_" + str(level), {})
