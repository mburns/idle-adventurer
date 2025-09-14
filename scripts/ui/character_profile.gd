extends BaseScreen

func on_screen_ready() -> void:
	"""Override base screen ready for character profile specific setup"""
	if not validate_character():
		return

	update_ui()

func update_ui():
	if character == null:
		return

	# Update character basic info
	var name_label = %CharacterNameLabel
	var level_label = %LevelLabel
	var class_label = %ClassLabel

	if name_label:
		name_label.text = character.name
	else:
		print("Warning: CharacterNameLabel not found in character profile")

	if level_label:
		level_label.text = "Level %d" % character.level
	else:
		print("Warning: LevelLabel not found in character profile")

	if class_label:
		class_label.text = "%s %s" % [character.race, character.character_class]
	else:
		print("Warning: ClassLabel not found in character profile")

	# Update ability scores
	var strength_label = %StrengthLabel
	var dexterity_label = %DexterityLabel
	var constitution_label = %ConstitutionLabel
	var intelligence_label = %IntelligenceLabel
	var wisdom_label = %WisdomLabel
	var charisma_label = %CharismaLabel

	if strength_label:
		strength_label.text = "Strength: %d (%+d)" % [character.strength, character.get_strength_modifier()]
	else:
		print("Warning: StrengthLabel not found in character profile")

	if dexterity_label:
		dexterity_label.text = "Dexterity: %d (%+d)" % [character.dexterity, character.get_dexterity_modifier()]
	else:
		print("Warning: DexterityLabel not found in character profile")

	if constitution_label:
		constitution_label.text = "Constitution: %d (%+d)" % [character.constitution, character.get_constitution_modifier()]
	else:
		print("Warning: ConstitutionLabel not found in character profile")

	if intelligence_label:
		intelligence_label.text = "Intelligence: %d (%+d)" % [character.intelligence, character.get_intelligence_modifier()]
	else:
		print("Warning: IntelligenceLabel not found in character profile")

	if wisdom_label:
		wisdom_label.text = "Wisdom: %d (%+d)" % [character.wisdom, character.get_wisdom_modifier()]
	else:
		print("Warning: WisdomLabel not found in character profile")

	if charisma_label:
		charisma_label.text = "Charisma: %d (%+d)" % [character.charisma, character.get_charisma_modifier()]
	else:
		print("Warning: CharismaLabel not found in character profile")

	# Update combat stats
	var hit_points_label = %HitPointsLabel
	var armor_class_label = %ArmorClassLabel
	var proficiency_bonus_label = %ProficiencyBonusLabel

	if hit_points_label:
		hit_points_label.text = "Hit Points: %d/%d" % [character.hit_points, character.max_hit_points]
	else:
		print("Warning: HitPointsLabel not found in character profile")

	if armor_class_label:
		armor_class_label.text = "Armor Class: %d" % character.armor_class
	else:
		print("Warning: ArmorClassLabel not found in character profile")

	if proficiency_bonus_label:
		proficiency_bonus_label.text = "Proficiency Bonus: %+d" % character.proficiency_bonus
	else:
		print("Warning: ProficiencyBonusLabel not found in character profile")

	# Update proficiencies
	update_skills_list()
	update_tools_list()
	update_languages_list()

func update_skills_list():
	var skills_text = ""
	if character.skill_proficiencies.size() > 0:
		for skill in character.skill_proficiencies:
			skills_text += skill + "\n"
	else:
		skills_text = "None"

	var skills_list = %SkillsList
	if skills_list:
		skills_list.text = skills_text
	else:
		print("Warning: SkillsList not found in character profile")

func update_tools_list():
	var tools_text = ""
	if character.tool_proficiencies.size() > 0:
		for tool in character.tool_proficiencies:
			tools_text += tool + "\n"
	else:
		tools_text = "None"

	var tools_list = %ToolsList
	if tools_list:
		tools_list.text = tools_text
	else:
		print("Warning: ToolsList not found in character profile")

func update_languages_list():
	var languages_text = ""
	if character.language_proficiencies.size() > 0:
		for language in character.language_proficiencies:
			languages_text += language + "\n"
	else:
		languages_text = "None"

	var languages_list = %LanguagesList
	if languages_list:
		languages_list.text = languages_text
	else:
		print("Warning: LanguagesList not found in character profile")

# Back button is handled by base class
