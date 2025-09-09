extends Control

var character: Character
var character_manager: CharacterManager

func _ready():
    # Get character manager and current character
    character_manager = CharacterManager.new()
    character = character_manager.get_current_character()

    if character == null:
        print("Error: No character found")
        return

    update_ui()

func update_ui():
    if character == null:
        return

    # Update character basic info
    %CharacterNameLabel.text = character.name
    %LevelLabel.text = "Level %d" % character.level
    %ClassLabel.text = "%s %s" % [character.race, character.character_class]

    # Update ability scores
    %StrengthLabel.text = "Strength: %d (%+d)" % [character.strength, character.get_strength_modifier()]
    %DexterityLabel.text = "Dexterity: %d (%+d)" % [character.dexterity, character.get_dexterity_modifier()]
    %ConstitutionLabel.text = "Constitution: %d (%+d)" % [character.constitution, character.get_constitution_modifier()]
    %IntelligenceLabel.text = "Intelligence: %d (%+d)" % [character.intelligence, character.get_intelligence_modifier()]
    %WisdomLabel.text = "Wisdom: %d (%+d)" % [character.wisdom, character.get_wisdom_modifier()]
    %CharismaLabel.text = "Charisma: %d (%+d)" % [character.charisma, character.get_charisma_modifier()]

    # Update combat stats
    %HitPointsLabel.text = "Hit Points: %d/%d" % [character.hit_points, character.max_hit_points]
    %ArmorClassLabel.text = "Armor Class: %d" % character.armor_class
    %ProficiencyBonusLabel.text = "Proficiency Bonus: %+d" % character.proficiency_bonus

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

    %SkillsList.text = skills_text

func update_tools_list():
    var tools_text = ""
    if character.tool_proficiencies.size() > 0:
        for tool in character.tool_proficiencies:
            tools_text += tool + "\n"
    else:
        tools_text = "None"

    %ToolsList.text = tools_text

func update_languages_list():
    var languages_text = ""
    if character.language_proficiencies.size() > 0:
        for language in character.language_proficiencies:
            languages_text += language + "\n"
    else:
        languages_text = "None"

    %LanguagesList.text = languages_text

func _on_back_button_pressed():
    get_tree().change_scene_to_file("res://scenes/main.tscn")
