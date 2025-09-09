class_name WikiDataLoader
extends Resource

# Loads D&D data from the wiki markdown files

static func load_class_from_wiki(class_type: String) -> Dictionary:
    var file_path = "res://wiki/Classes/%s.md" % class_type.capitalize()
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        print("Warning: Could not load class file: " + file_path)
        return {}

    var content = file.get_as_text()
    file.close()

    return parse_class_markdown(content, class_type)

static func load_equipment_from_wiki() -> Dictionary:
    var equipment = {}

    # Load armor
    var armor_file = FileAccess.open("res://wiki/Equipment/Armor.md", FileAccess.READ)
    if armor_file:
        equipment["armor"] = parse_equipment_markdown(armor_file.get_as_text())
        armor_file.close()

    # Load weapons
    var weapons_file = FileAccess.open("res://wiki/Equipment/Weapons.md", FileAccess.READ)
    if weapons_file:
        equipment["weapons"] = parse_equipment_markdown(weapons_file.get_as_text())
        weapons_file.close()

    # Load other equipment
    var equipment_files = [
        "res://wiki/Equipment/Adventuring Gear.md",
        "res://wiki/Equipment/Tools.md",
        "res://wiki/Equipment/Coinage.md"
    ]

    for file_path in equipment_files:
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var category = file_path.get_file().get_basename().to_lower()
            equipment[category] = parse_equipment_markdown(file.get_as_text())
            file.close()

    return equipment

static func load_treasure_from_wiki() -> Dictionary:
    var treasure = {}
    var treasure_dir = DirAccess.open("res://wiki/Treasure/")
    if treasure_dir:
        for file_name in treasure_dir.get_files():
            if file_name.ends_with(".md"):
                var file_path = "res://wiki/Treasure/" + file_name
                var file = FileAccess.open(file_path, FileAccess.READ)
                if file:
                    var item_name = file_name.get_basename()
                    treasure[item_name] = parse_treasure_markdown(file.get_as_text())
                    file.close()

    return treasure

static func load_spells_from_wiki() -> Dictionary:
    var spells = {}
    var spells_dir = DirAccess.open("res://wiki/Spells/")
    if spells_dir:
        for file_name in spells_dir.get_files():
            if file_name.ends_with(".md"):
                var file_path = "res://wiki/Spells/" + file_name
                var file = FileAccess.open(file_path, FileAccess.READ)
                if file:
                    var spell_name = file_name.get_basename()
                    spells[spell_name] = parse_spell_markdown(file.get_as_text())
                    file.close()

    return spells

static func load_abilities_from_wiki() -> Dictionary:
    var abilities = {}
    var ability_files = [
        "res://wiki/Gameplay/Abilities/Strength.md",
        "res://wiki/Gameplay/Abilities/Dexterity.md",
        "res://wiki/Gameplay/Abilities/Constitution.md",
        "res://wiki/Gameplay/Abilities/Intelligence.md",
        "res://wiki/Gameplay/Abilities/Wisdom.md",
        "res://wiki/Gameplay/Abilities/Charisma.md"
    ]

    for file_path in ability_files:
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var ability_name = file_path.get_file().get_basename().to_lower()
            abilities[ability_name] = parse_ability_markdown(file.get_as_text())
            file.close()

    return abilities

static func load_races_from_wiki() -> Dictionary:
    var races = {}
    var races_dir = DirAccess.open("res://wiki/Races/")
    if races_dir:
        for file_name in races_dir.get_files():
            if file_name.ends_with(".md"):
                var file_path = "res://wiki/Races/" + file_name
                var file = FileAccess.open(file_path, FileAccess.READ)
                if file:
                    var race_name = file_name.get_basename().to_lower()
                    races[race_name] = parse_race_markdown(file.get_as_text())
                    file.close()

    return races

static func load_backgrounds_from_wiki() -> Dictionary:
    var backgrounds = {}
    var backgrounds_file = FileAccess.open("res://wiki/Meta/Characterizations/Backgrounds.md", FileAccess.READ)
    if backgrounds_file:
        backgrounds = parse_backgrounds_markdown(backgrounds_file.get_as_text())
        backgrounds_file.close()

    return backgrounds

static func load_monsters_from_wiki() -> Dictionary:
    var monsters = {}
    var monsters_dir = DirAccess.open("res://wiki/Monsters/")
    if monsters_dir:
        for file_name in monsters_dir.get_files():
            if file_name.ends_with(".md"):
                var file_path = "res://wiki/Monsters/" + file_name
                var file = FileAccess.open(file_path, FileAccess.READ)
                if file:
                    var monster_name = file_name.get_basename().to_lower()
                    monsters[monster_name] = parse_monster_markdown(file.get_as_text())
                    file.close()

    return monsters

static func load_conditions_from_wiki() -> Dictionary:
    var conditions = {}
    var conditions_file = FileAccess.open("res://wiki/Meta/Gamemastering/Conditions.md", FileAccess.READ)
    if conditions_file:
        conditions = parse_conditions_markdown(conditions_file.get_as_text())
        conditions_file.close()

    return conditions

static func load_languages_from_wiki() -> Dictionary:
    var languages = {}
    var languages_file = FileAccess.open("res://wiki/Meta/Characterizations/Languages.md", FileAccess.READ)
    if languages_file:
        languages = parse_languages_markdown(languages_file.get_as_text())
        languages_file.close()

    return languages

# Load all data at once
static func load_all_data() -> Dictionary:
    var data = {}
    data.classes = load_classes_from_wiki()
    data.races = load_races_from_wiki()
    data.backgrounds = load_backgrounds_from_wiki()
    data.equipment = load_equipment_from_wiki()
    data.spells = load_spells_from_wiki()
    data.treasure = load_treasure_from_wiki()
    data.abilities = load_abilities_from_wiki()
    data.monsters = load_monsters_from_wiki()
    data.conditions = load_conditions_from_wiki()
    data.languages = load_languages_from_wiki()
    return data

# Load all classes from wiki
static func load_classes_from_wiki() -> Dictionary:
    var classes = {}
    var classes_dir = DirAccess.open("res://wiki/Classes/")
    if classes_dir:
        for file_name in classes_dir.get_files():
            if file_name.ends_with(".md"):
                var class_type = file_name.get_basename().to_lower()
                classes[class_type] = load_class_from_wiki(class_type)

    return classes

# Parse class markdown content
static func parse_class_markdown(content: String, class_type: String) -> Dictionary:
    var lines = content.split("\n")
    var class_data = {
        "name": class_type,
        "hit_die": 8,
        "primary_ability": "strength",
        "saving_throws": [],
        "skill_choices": 2,
        "skill_options": [],
        "armor_proficiencies": [],
        "weapon_proficiencies": [],
        "tool_proficiencies": [],
        "starting_equipment": {},
        "features": []
    }

    var current_section = ""

    for line in lines:
        line = line.strip_edges()

        if line.begins_with("### "):
            current_section = line.substr(4).to_lower()
        elif line.begins_with("**Hit Dice:**"):
            var hit_dice_text = line.split(":")[1].strip_edges()
            class_data.hit_die = extract_hit_die(hit_dice_text)
        elif line.begins_with("**Saving Throws:**"):
            var saves_text = line.split(":")[1].strip_edges()
            class_data.saving_throws = parse_saving_throws(saves_text)
        elif line.begins_with("**Skills:**"):
            var skills_text = line.split(":")[1].strip_edges()
            class_data.skill_options = parse_skill_options(skills_text)
        elif line.begins_with("**Armor:**"):
            var armor_text = line.split(":")[1].strip_edges()
            class_data.armor_proficiencies = parse_proficiencies(armor_text)
        elif line.begins_with("**Weapons:**"):
            var weapons_text = line.split(":")[1].strip_edges()
            class_data.weapon_proficiencies = parse_proficiencies(weapons_text)
        elif line.begins_with("**Tools:**"):
            var tools_text = line.split(":")[1].strip_edges()
            class_data.tool_proficiencies = parse_proficiencies(tools_text)
        elif current_section == "equipment" and line.begins_with("-"):
            # Parse starting equipment options like "- (a) a quarterstaff or (b) a dagger"
            if not class_data.starting_equipment.has("options"):
                class_data.starting_equipment["options"] = []
            class_data.starting_equipment.options.append(line.substr(2))

    return class_data

# Parse equipment markdown content
static func parse_equipment_markdown(content: String) -> Array[Dictionary]:
    var equipment = []
    var lines = content.split("\n")

    for line in lines:
        line = line.strip_edges()
        if line.begins_with("|") and not line.begins_with("|---"):
            var parts = line.split("|")
            if parts.size() >= 3:
                var item = {
                    "name": parts[1].strip_edges(),
                    "cost": parts[2].strip_edges() if parts.size() > 2 else "",
                    "weight": parts[3].strip_edges() if parts.size() > 3 else "",
                    "description": parts[4].strip_edges() if parts.size() > 4 else ""
                }
                equipment.append(item)

    return equipment

# Parse treasure markdown content
static func parse_treasure_markdown(content: String) -> Dictionary:
    var treasure = {
        "name": "",
        "type": "wondrous item",
        "rarity": "common",
        "description": "",
        "properties": []
    }

    var lines = content.split("\n")
    for line in lines:
        line = line.strip_edges()
        if line.begins_with("# "):
            treasure.name = line.substr(2)
        elif line.begins_with("**Type:**"):
            treasure.type = line.split(":")[1].strip_edges()
        elif line.begins_with("**Rarity:**"):
            treasure.rarity = line.split(":")[1].strip_edges()
        elif line.begins_with("- "):
            treasure.properties.append(line.substr(2))
        elif line != "" and not line.begins_with("#") and not line.begins_with("**"):
            treasure.description += line + " "

    return treasure

# Parse spell markdown content
static func parse_spell_markdown(content: String) -> Dictionary:
    var spell = {
        "name": "",
        "level": 0,
        "school": "evocation",
        "casting_time": "1 action",
        "range": "60 feet",
        "components": "V, S",
        "duration": "instantaneous",
        "description": ""
    }

    var lines = content.split("\n")
    for line in lines:
        line = line.strip_edges()
        if line.begins_with("# "):
            spell.name = line.substr(2)
        elif line.begins_with("**Level:**"):
            spell.level = int(line.split(":")[1].strip_edges())
        elif line.begins_with("**School:**"):
            spell.school = line.split(":")[1].strip_edges()
        elif line.begins_with("**Casting Time:**"):
            spell.casting_time = line.split(":")[1].strip_edges()
        elif line.begins_with("**Range:**"):
            spell.range = line.split(":")[1].strip_edges()
        elif line.begins_with("**Components:**"):
            spell.components = line.split(":")[1].strip_edges()
        elif line.begins_with("**Duration:**"):
            spell.duration = line.split(":")[1].strip_edges()
        elif line != "" and not line.begins_with("#") and not line.begins_with("**"):
            spell.description += line + " "

    return spell

# Parse ability markdown content
static func parse_ability_markdown(content: String) -> Dictionary:
    var ability = {
        "name": "",
        "description": "",
        "skills": []
    }

    var lines = content.split("\n")
    var current_section = ""

    for line in lines:
        line = line.strip_edges()
        if line.begins_with("### "):
            ability.name = line.substr(4)
        elif line.begins_with("***") and line.ends_with("***"):
            # Skill name
            var skill_name = line.replace("*", "").strip_edges()
            ability.skills.append(skill_name)
        elif line != "" and not line.begins_with("#") and not line.begins_with("**"):
            ability.description += line + " "

    return ability

# Helper functions
static func extract_hit_die(text: String) -> int:
    var regex = RegEx.new()
    regex.compile("(\\d+)d(\\d+)")
    var result = regex.search(text)
    if result:
        return int(result.get_string(2))
    return 8

static func parse_saving_throws(text: String) -> Array[String]:
    var saves = []
    var parts = text.split(",")
    for part in parts:
        saves.append(part.strip_edges().capitalize())
    return saves

static func parse_skill_options(text: String) -> Array[String]:
    var skills = []
    var parts = text.split(",")
    for part in parts:
        skills.append(part.strip_edges())
    return skills

static func parse_proficiencies(text: String) -> Array[String]:
    var proficiencies = []
    var parts = text.split(",")
    for part in parts:
        proficiencies.append(part.strip_edges())
    return proficiencies

# Parse race markdown content
static func parse_race_markdown(content: String) -> Dictionary:
    var race = {
        "name": "",
        "ability_score_increase": {},
        "age": "",
        "alignment": "",
        "size": "Medium",
        "speed": 30,
        "languages": [],
        "traits": []
    }

    var lines = content.split("\n")
    var current_section = ""

    for line in lines:
        line = line.strip_edges()

        if line.begins_with("# "):
            race.name = line.substr(2)
        elif line.begins_with("***Ability Score Increase***"):
            var next_line = get_next_non_empty_line(lines, lines.find(line))
            if next_line != "":
                race.ability_score_increase = parse_ability_increases(next_line)
        elif line.begins_with("***Age***"):
            var next_line = get_next_non_empty_line(lines, lines.find(line))
            if next_line != "":
                race.age = next_line
        elif line.begins_with("***Alignment***"):
            var next_line = get_next_non_empty_line(lines, lines.find(line))
            if next_line != "":
                race.alignment = next_line
        elif line.begins_with("***Size***"):
            var next_line = get_next_non_empty_line(lines, lines.find(line))
            if next_line != "":
                race.size = extract_size(next_line)
        elif line.begins_with("***Speed***"):
            var next_line = get_next_non_empty_line(lines, lines.find(line))
            if next_line != "":
                race.speed = extract_speed(next_line)
        elif line.begins_with("***Languages***"):
            var next_line = get_next_non_empty_line(lines, lines.find(line))
            if next_line != "":
                race.languages = parse_languages(next_line)
        elif line.begins_with("***") and line.ends_with("***"):
            # Race trait
            var trait_name = line.replace("*", "").strip_edges()
            var trait_desc = get_next_non_empty_line(lines, lines.find(line))
            race.traits.append({"name": trait_name, "description": trait_desc})

    return race

# Parse backgrounds markdown content
static func parse_backgrounds_markdown(content: String) -> Dictionary:
    var backgrounds = {}
    var lines = content.split("\n")
    var current_background = ""

    for line in lines:
        line = line.strip_edges()

        if line.begins_with("### "):
            current_background = line.substr(4).to_lower()
            backgrounds[current_background] = {
                "name": line.substr(4),
                "proficiencies": [],
                "languages": [],
                "equipment": [],
                "features": []
            }
        elif current_background != "" and line.begins_with("- "):
            # Add to current background
            pass # TODO: Implement background parsing

    return backgrounds

# Parse monster markdown content
static func parse_monster_markdown(content: String) -> Dictionary:
    var monster = {
        "name": "",
        "size": "Medium",
        "type": "humanoid",
        "alignment": "neutral",
        "armor_class": 10,
        "hit_points": 1,
        "speed": "30 ft.",
        "abilities": {},
        "challenge_rating": "1/4"
    }

    var lines = content.split("\n")

    for line in lines:
        line = line.strip_edges()

        if line.begins_with("# "):
            monster.name = line.substr(2)
        elif line.begins_with("**Armor Class**"):
            monster.armor_class = extract_number(line.split(":")[1])
        elif line.begins_with("**Hit Points**"):
            monster.hit_points = extract_number(line.split(":")[1])
        elif line.begins_with("**Speed**"):
            monster.speed = line.split(":")[1].strip_edges()
        elif line.begins_with("**STR**"):
            monster.abilities["strength"] = extract_ability_score(line)
        elif line.begins_with("**DEX**"):
            monster.abilities["dexterity"] = extract_ability_score(line)
        elif line.begins_with("**CON**"):
            monster.abilities["constitution"] = extract_ability_score(line)
        elif line.begins_with("**INT**"):
            monster.abilities["intelligence"] = extract_ability_score(line)
        elif line.begins_with("**WIS**"):
            monster.abilities["wisdom"] = extract_ability_score(line)
        elif line.begins_with("**CHA**"):
            monster.abilities["charisma"] = extract_ability_score(line)

    return monster

# Parse conditions markdown content
static func parse_conditions_markdown(content: String) -> Dictionary:
    var conditions = {}
    var lines = content.split("\n")
    var current_condition = ""

    for line in lines:
        line = line.strip_edges()

        if line.begins_with("### "):
            current_condition = line.substr(4).to_lower()
            conditions[current_condition] = {
                "name": line.substr(4),
                "description": ""
            }
        elif current_condition != "" and line != "":
            conditions[current_condition].description += line + " "

    return conditions

# Parse languages markdown content
static func parse_languages_markdown(content: String) -> Dictionary:
    var languages = {
        "common": {"name": "Common", "script": "Common", "typical_speakers": "Humans"},
        "dwarvish": {"name": "Dwarvish", "script": "Dwarvish", "typical_speakers": "Dwarves"},
        "elvish": {"name": "Elvish", "script": "Elvish", "typical_speakers": "Elves"},
        "giant": {"name": "Giant", "script": "Dwarvish", "typical_speakers": "Ogres, Giants"},
        "gnomish": {"name": "Gnomish", "script": "Dwarvish", "typical_speakers": "Gnomes"},
        "goblin": {"name": "Goblin", "script": "Dwarvish", "typical_speakers": "Goblinoids"},
        "halfling": {"name": "Halfling", "script": "Common", "typical_speakers": "Halflings"},
        "orc": {"name": "Orc", "script": "Dwarvish", "typical_speakers": "Orcs"}
    }

    return languages

# Helper functions for parsing
static func get_next_non_empty_line(lines: Array, start_index: int) -> String:
    for i in range(start_index + 1, lines.size()):
        var line = lines[i].strip_edges()
        if line != "":
            return line
    return ""

static func parse_ability_increases(text: String) -> Dictionary:
    var increases = {}
    var parts = text.split(",")
    for part in parts:
        part = part.strip_edges()
        if "Strength" in part:
            increases["strength"] = extract_number(part)
        elif "Dexterity" in part:
            increases["dexterity"] = extract_number(part)
        elif "Constitution" in part:
            increases["constitution"] = extract_number(part)
        elif "Intelligence" in part:
            increases["intelligence"] = extract_number(part)
        elif "Wisdom" in part:
            increases["wisdom"] = extract_number(part)
        elif "Charisma" in part:
            increases["charisma"] = extract_number(part)
    return increases

static func extract_size(text: String) -> String:
    if "Small" in text:
        return "Small"
    elif "Large" in text:
        return "Large"
    elif "Huge" in text:
        return "Huge"
    elif "Gargantuan" in text:
        return "Gargantuan"
    else:
        return "Medium"

static func extract_speed(text: String) -> int:
    var regex = RegEx.new()
    regex.compile("(\\d+)")
    var result = regex.search(text)
    if result:
        return int(result.get_string(1))
    return 30

static func parse_languages(text: String) -> Array[String]:
    var languages: Array[String] = []
    var parts = text.split(",")
    for part in parts:
        languages.append(part.strip_edges())
    return languages

static func extract_number(text: String) -> int:
    var regex = RegEx.new()
    regex.compile("(\\d+)")
    var result = regex.search(text)
    if result:
        return int(result.get_string(1))
    return 0

static func extract_ability_score(text: String) -> int:
    var regex = RegEx.new()
    regex.compile("(\\d+)")
    var result = regex.search(text)
    if result:
        return int(result.get_string(1))
    return 10
