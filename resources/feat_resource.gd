extends Resource

class_name FeatResource

@export var feat_name: String = ""
@export var description: String = ""
@export var prerequisites: Dictionary = {}  # Ability scores, class, level requirements
@export var benefits: Array[String] = []  # What the feat provides
@export var is_combat_feat: bool = false  # Does this feat affect combat
@export var is_skill_feat: bool = false  # Does this feat affect skills
@export var is_magic_feat: bool = false  # Does this feat provide magical abilities
@export var ability_score_increase: Dictionary = {}  # Which abilities get +1 (max 2 total)
@export var skill_proficiencies: Array[String] = []  # Skills this feat grants proficiency in
@export var tool_proficiencies: Array[String] = []  # Tools this feat grants proficiency in
@export var language_proficiencies: Array[String] = []  # Languages this feat grants
@export var weapon_proficiencies: Array[String] = []  # Weapons this feat grants proficiency in
@export var armor_proficiencies: Array[String] = []  # Armor this feat grants proficiency in
@export var saving_throw_proficiencies: Array[String] = []  # Saving throws this feat grants
@export var spell_slots: Dictionary = {}  # Additional spell slots granted
@export var spells_known: Array[String] = []  # Spells this feat grants
@export var special_abilities: Array[String] = []  # Unique abilities granted
@export var is_half_feat: bool = false  # Does this feat grant +1 to an ability score
@export var can_take_multiple_times: bool = false  # Can this feat be taken multiple times
@export var source_book: String = "PHB"  # Which book this feat comes from
@export var rarity: String = "common"  # How common this feat is

func get_display_name() -> String:
	"""Get the display name for the feat"""
	return feat_name

func get_full_description() -> String:
	"""Get the full description including prerequisites and benefits"""
	var desc = description

	if not prerequisites.is_empty():
		desc += "\n\nPrerequisites: "
		var prereq_parts = []
		for key in prerequisites.keys():
			prereq_parts.append(key + " " + str(prerequisites[key]))
		desc += ", ".join(prereq_parts)

	if not benefits.is_empty():
		desc += "\n\nBenefits:"
		for benefit in benefits:
			desc += "\n• " + benefit

	return desc

func can_take(character) -> bool:
	"""Check if a character can take this feat"""
	# Check ability score prerequisites
	for ability in prerequisites.keys():
		if ability in ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]:
			if character.get_ability_score(ability) < prerequisites[ability]:
				return false

	# Check class prerequisites
	if "class" in prerequisites:
		if not character.character_class in prerequisites["class"]:
			return false

	# Check level prerequisites
	if "level" in prerequisites:
		if character.level < prerequisites["level"]:
			return false

	# Check if character already has this feat (unless it can be taken multiple times)
	if not can_take_multiple_times and character.has_feat(feat_name):
		return false

	return true

func get_ability_score_increase() -> Dictionary:
	"""Get the ability score increases this feat provides"""
	return ability_score_increase

func is_half_ability_score_feat() -> bool:
	"""Check if this is a half feat (grants +1 to an ability score)"""
	return is_half_feat or not ability_score_increase.is_empty()
