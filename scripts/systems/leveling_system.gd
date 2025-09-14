extends Node

# Leveling system with difficult progression to level 20

class_name LevelingSystem

signal level_up(character: Character, new_level: int)
signal ability_score_increase(character: Character, ability: String, new_score: int)
signal class_feature_unlocked(character: Character, feature: String)

# Experience requirements loaded from YAML
var level_requirements: Dictionary = {}  # level -> experience_required
var leveling_configs: Dictionary = {}    # config_name -> level_requirements
var current_config: String = "standard"  # Current leveling configuration

# Class features loaded from YAML files
var class_features: Dictionary = {}  # class_id -> {level: [features]}

var character_experience: Dictionary = {} # character_name -> total_experience

func _init() -> void:
    setup_leveling_system()

func setup_leveling_system() -> void:
    """Initialize the leveling system"""
    load_level_requirements()
    load_class_features()
    print("Leveling System initialized")

func add_experience(character: Character, amount: float) -> void:
    """Add experience to a character and check for level up"""
    var current_exp = character_experience.get(character.name, 0.0)
    var new_exp = current_exp + amount
    character_experience[character.name] = new_exp

    # Check for level up
    var new_level = get_level_from_experience(new_exp)
    if new_level > character.level:
        level_up_character(character, new_level)

func get_level_from_experience(experience: float) -> int:
    """Get character level from total experience"""
    var level = 1

    for req_level in level_requirements.keys():
        if experience >= level_requirements[req_level]:
            level = req_level
        else:
            break

    return level

func get_experience_for_level(level: int) -> int:
    """Get experience required for a specific level"""
    return level_requirements.get(level, 0)

func get_experience_to_next_level(character: Character) -> int:
    """Get experience needed to reach next level"""
    var current_level = character.level
    var next_level = current_level + 1

    if next_level > 20:
        return 0 # Max level reached

    var current_exp = character_experience.get(character.name, 0.0)
    var required_exp = get_experience_for_level(next_level)

    return max(0, required_exp - int(current_exp))

func level_up_character(character: Character, new_level: int) -> void:
    """Level up a character and apply benefits"""
    var old_level = character.level
    character.level = new_level

    # Apply class features for this level
    apply_class_features(character, new_level)

    # Apply ability score improvements
    apply_ability_score_improvements(character, new_level)

    # Update hit points
    update_hit_points(character, new_level)

    level_up.emit(character, new_level)
    print(character.name + " leveled up to " + str(new_level) + "!")

func apply_class_features(character: Character, level: int) -> void:
    """Apply class features for a level"""
    var character_class = character.character_class.to_lower()
    var features = class_features.get(character_class, {})
    var level_features = features.get(level, [])

    for feature in level_features:
        unlock_class_feature(character, feature)
        class_feature_unlocked.emit(character, feature)

func unlock_class_feature(character: Character, feature: String) -> void:
    """Unlock a specific class feature"""
    if not character.has_method("add_class_feature"):
        # Add to character's class features if the method exists
        print(character.name + " unlocked: " + feature)
    else:
        character.add_class_feature(feature)

func apply_ability_score_improvements(character: Character, level: int) -> void:
    """Apply ability score improvements at certain levels"""
    var improvement_levels = [4, 6, 8, 12, 14, 16, 19]

    if level in improvement_levels:
        # Allow player to choose which ability to improve
        # For now, automatically improve the highest ability
        var abilities = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]
        var highest_ability = "strength"
        var highest_score = character.strength

        for ability in abilities:
            var score = character.get(ability)
            if score > highest_score:
                highest_score = score
                highest_ability = ability

        # Increase ability score (max 20)
        if highest_score < 20:
            character.set(highest_ability, highest_score + 1)
            ability_score_increase.emit(character, highest_ability, highest_score + 1)
            print(character.name + " increased " + highest_ability + " to " + str(highest_score + 1))

func update_hit_points(character: Character, new_level: int) -> void:
    """Update hit points for level up"""
    var constitution_modifier = get_ability_modifier(character.constitution)
    var hit_die = get_class_hit_die(character.character_class)

    # Roll hit die and add constitution modifier
    var hit_points_gained = randi_range(1, hit_die) + constitution_modifier
    character.hit_points += hit_points_gained
    character.max_hit_points += hit_points_gained

    print(character.name + " gained " + str(hit_points_gained) + " hit points")

func get_ability_modifier(ability_score: int) -> int:
    """Get ability modifier from ability score"""
    return (ability_score - 10) / 2

func get_class_hit_die(character_class: String) -> int:
    """Get hit die for a character class"""
    match character_class.to_lower():
        "fighter", "paladin", "ranger":
            return 10
        "barbarian":
            return 12
        "wizard", "sorcerer":
            return 6
        "cleric", "druid", "monk", "rogue", "warlock":
            return 8
        "bard":
            return 8
        _:
            return 8

func get_character_progress(character: Character) -> Dictionary:
    """Get character's leveling progress"""
    var current_exp = character_experience.get(character.name, 0.0)
    var current_level = character.level
    var next_level = current_level + 1

    var current_level_exp = get_experience_for_level(current_level)
    var next_level_exp = get_experience_for_level(next_level)

    var progress = 0.0
    if next_level <= 20:
        var exp_in_level = current_exp - current_level_exp
        var exp_needed = next_level_exp - current_level_exp
        progress = float(exp_in_level) / float(exp_needed)

    return {
        "current_level": current_level,
        "current_experience": int(current_exp),
        "next_level": next_level,
        "experience_to_next": get_experience_to_next_level(character),
        "progress": progress,
        "is_max_level": current_level >= 20
    }

func get_leveling_difficulty_multiplier(level: int) -> float:
    """Get difficulty multiplier for gaining experience at a level"""
    if level >= 20:
        return 0.0 # No experience gain at max level

    # Exponential difficulty increase
    return 1.0 + (level - 1) * 0.2

func calculate_experience_reward(base_reward: float, character_level: int) -> float:
    """Calculate experience reward scaled by character level"""
    var difficulty_multiplier = get_leveling_difficulty_multiplier(character_level)
    return base_reward / difficulty_multiplier

func get_character_by_name(name: String) -> Character:
    """Get character by name (placeholder - would use CharacterManager)"""
    # This would be implemented with proper character management
    return null

# Level requirements loading functions
func load_level_requirements() -> void:
    """Load level requirements from YAML file"""
    var file_path = "res://data/level_requirements.yaml"
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        print("Error: Could not open level requirements file: " + file_path)
        return

    var yaml_string = file.get_as_text()
    file.close()

    var level_config = parse_yaml_level_requirements(yaml_string)
    if level_config == null:
        print("Error parsing level requirements YAML")
        return

    # Load main level requirements
    var main_requirements = level_config.get("level_requirements", {})
    if main_requirements is Dictionary and main_requirements.size() > 0:
        level_requirements = main_requirements
        print("Loaded " + str(level_requirements.size()) + " level requirements")
    else:
        print("Warning: level_requirements is not a Dictionary, got: ", typeof(main_requirements))

    # Load alternative configurations
    var alternative_configs = level_config.get("alternative_configs", {})
    if alternative_configs is Dictionary:
        for config_name in alternative_configs.keys():
            leveling_configs[config_name] = alternative_configs[config_name]
    else:
        print("Warning: alternative_configs is not a Dictionary, got: ", typeof(alternative_configs))

    # Load configuration info
    var config_info = level_config.get("config_info", {})
    if config_info is Dictionary:
        current_config = config_info.get("default_config", "standard")
    else:
        print("Warning: config_info is not a Dictionary, got: ", typeof(config_info))
        current_config = "standard"

    print("Loaded " + str(leveling_configs.size()) + " alternative leveling configurations")

func set_leveling_config(config_name: String) -> bool:
    """Switch to a different leveling configuration"""
    if not leveling_configs.has(config_name):
        print("Error: Leveling configuration '" + config_name + "' not found")
        return false

    level_requirements = leveling_configs[config_name]
    current_config = config_name
    print("Switched to leveling configuration: " + config_name)
    return true

func get_available_configs() -> Array:
    """Get list of available leveling configurations"""
    return leveling_configs.keys()

func get_current_config() -> String:
    """Get the current leveling configuration name"""
    return current_config

func parse_yaml_level_requirements(yaml_string: String) -> Dictionary:
    """Parse YAML level requirements configuration"""
    var lines = yaml_string.split("\n")
    var result = {}
    var current_key = ""
    var current_value = ""
    var in_multiline = false
    var indent_level = 0
    var current_object = {}
    var in_object = false
    var object_key = ""

    for line in lines:
        line = line.strip_edges()
        if line.is_empty() or line.begins_with("#"):
            continue

        var line_indent = get_indent_level(line)

        # Handle top-level keys
        if line_indent == 0 and ":" in line and not line.begins_with("-"):
            if in_multiline and current_key != "":
                result[current_key] = current_value.strip_edges()
                in_multiline = false

            var parts = line.split(":", 1)
            current_key = parts[0].strip_edges()
            var value = parts[1].strip_edges()

            if value.is_empty():
                in_multiline = true
                current_value = ""
            else:
                result[current_key] = parse_value(value)
        elif line_indent > 0 and ":" in line:
            # Handle nested key-value pairs
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
            if in_object:
                current_object[object_key] += "\n" + line
            else:
                current_value += "\n" + line

    # Handle last key-value pair
    if in_multiline and current_key != "":
        result[current_key] = current_value.strip_edges()

    return result

# Class features loading functions
func load_class_features() -> void:
    """Load class features from YAML files"""
    var classes_dir = "res://data/classes/"
    var dir = DirAccess.open(classes_dir)

    if dir == null:
        print("Error: Could not open classes directory: " + classes_dir)
        return

    dir.list_dir_begin()
    var file_name = dir.get_next()

    while file_name != "":
        if file_name.ends_with(".yaml"):
            var class_id = file_name.get_basename()
            var file_path = classes_dir + file_name
            load_class_features_from_file(class_id, file_path)
        file_name = dir.get_next()

    print("Loaded class features for " + str(class_features.size()) + " classes")

func load_class_features_from_file(class_id: String, file_path: String) -> void:
    """Load class features from a specific YAML file"""
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        print("Error: Could not open class file: " + file_path)
        return

    var yaml_string = file.get_as_text()
    file.close()

    var class_data = parse_yaml_class_features(yaml_string)
    if class_data == null:
        print("Error parsing class features for: " + class_id)
        return

    var level_features = class_data.get("level_features", {})
    if level_features.size() > 0:
        class_features[class_id] = level_features
        print("Loaded " + str(level_features.size()) + " levels for " + class_id)

func parse_yaml_class_features(yaml_string: String) -> Dictionary:
    """Parse YAML class features configuration"""
    var lines = yaml_string.split("\n")
    var result = {}
    var current_key = ""
    var current_value = ""
    var in_multiline = false
    var indent_level = 0
    var current_array = []
    var in_array = false
    var current_object = {}
    var in_object = false
    var object_key = ""
    var in_level_features = false

    for line in lines:
        line = line.strip_edges()
        if line.is_empty() or line.begins_with("#"):
            continue

        var line_indent = get_indent_level(line)

        # Check if we're entering level_features section
        if line == "level_features:" and line_indent == 0:
            in_level_features = true
            current_key = "level_features"
            result[current_key] = {}
            continue

        # Handle level features section
        if in_level_features:
            if line_indent == 0 and ":" in line and not line.begins_with("-"):
                # We've left the level_features section
                in_level_features = false
                # Continue processing as normal
            elif line_indent == 0 and line.is_valid_int() and line.ends_with(":"):
                # Level number
                var level = line.get_basename().to_int()
                current_object = {}
                result[current_key][level] = []
                in_object = true
                continue
            elif line.begins_with("- ") and line_indent > 0:
                # Feature name
                var feature = line.substr(2).strip_edges()
                result[current_key][current_object.keys()[current_object.keys().size()-1]].append(feature)
                continue

        # Handle top-level keys (non-level_features)
        if line_indent == 0 and ":" in line and not line.begins_with("-") and not in_level_features:
            if in_multiline and current_key != "":
                result[current_key] = current_value.strip_edges()
                in_multiline = false

            var parts = line.split(":", 1)
            current_key = parts[0].strip_edges()
            var value = parts[1].strip_edges()

            if value.is_empty():
                in_multiline = true
                current_value = ""
            else:
                result[current_key] = parse_value(value)
        elif line.begins_with("- ") and line_indent == 0:
            # Handle array items
            if not in_array:
                in_array = true
                current_array = []
                result[current_key] = current_array

            # Start new object
            current_object = {}
            current_array.append(current_object)
            in_object = true
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
            if in_object:
                current_object[object_key] += "\n" + line
            else:
                current_value += "\n" + line

    # Handle last key-value pair
    if in_multiline and current_key != "":
        result[current_key] = current_value.strip_edges()

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
