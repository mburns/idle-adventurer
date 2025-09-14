extends Node

# Language learning system for D&D idle game

class_name LanguageSystem

signal language_learned(character: Character, language: String)
signal language_progress(character: Character, language: String, progress: float)

# Language data loaded from YAML
var available_languages: Dictionary = {}  # language_id -> language_data
var language_categories: Dictionary = {}  # category_id -> category_data
var difficulty_levels: Dictionary = {}   # difficulty -> difficulty_data

var learning_progress: Dictionary = {} # character_name -> {language: progress}

func _init():
    setup_language_system()

func setup_language_system():
    """Initialize the language learning system"""
    load_language_data()

    var timer = Timer.new()
    timer.wait_time = 1.0 # Check every second
    timer.timeout.connect(_process_language_learning)
    timer.autostart = true
    add_child(timer)

func get_available_languages_for_character(character: Character) -> Dictionary:
    """Get languages that character can learn (not already known)"""
    var available = {}

    for lang_id in available_languages.keys():
        if lang_id not in character.known_languages:
            available[lang_id] = available_languages[lang_id]

    return available

func can_learn_language(character: Character, language: String) -> bool:
    """Check if character can learn a specific language"""
    if language in character.known_languages:
        return false # Already known

    if not available_languages.has(language):
        return false # Language doesn't exist

    var lang_data = available_languages[language]
    var daily_cost = lang_data.get("cost_per_day", 0.0)

    # Check if character can afford the daily cost
    return character.gold >= daily_cost

func start_learning_language(character: Character, language: String) -> bool:
    """Start learning a language"""
    if not can_learn_language(character, language):
        return false

    var lang_data = available_languages[language]
    var learning_key = character.name + "_" + language

    learning_progress[learning_key] = {
        "language": language,
        "progress": 0.0,
        "total_days": lang_data.get("learning_time_days", 250),
        "cost_per_day": lang_data.get("cost_per_day", 1.0),
        "start_time": Time.get_unix_time_from_system(),
        "last_payment": Time.get_unix_time_from_system()
    }

    print(character.name + " started learning " + language)
    return true

func stop_learning_language(character: Character, language: String):
    """Stop learning a language"""
    var learning_key = character.name + "_" + language
    if learning_key in learning_progress:
        learning_progress.erase(learning_key)
        print(character.name + " stopped learning " + language)

func _process_language_learning():
    """Process all active language learning"""
    var current_time = Time.get_unix_time_from_system()

    for learning_key in learning_progress.keys():
        var learning_data = learning_progress[learning_key]
        var character_name = learning_key.split("_")[0]
        var language = learning_data["language"]

        var character = get_character_by_name(character_name)
        if not character:
            continue

        process_language_learning(character, learning_data, current_time)

func process_language_learning(character: Character, learning_data: Dictionary, current_time: float):
    """Process language learning for a character"""
    var days_elapsed = (current_time - learning_data["last_payment"]) / 86400.0

    if days_elapsed >= 1.0: # Process daily
        var daily_cost = learning_data.get("cost_per_day", 0.0)

        # Check if character can afford the cost
        if character.gold >= daily_cost:
            character.gold -= daily_cost

            # Add progress
            var daily_progress = 1.0 / learning_data.get("total_days", 250)
            learning_data["progress"] += daily_progress

            learning_data["last_payment"] = current_time
            language_progress.emit(character, learning_data["language"], learning_data["progress"])

            print(character.name + " learned " + str(daily_progress * 100) + "% of " + learning_data["language"])

            # Check for completion
            if learning_data["progress"] >= 1.0:
                complete_language_learning(character, learning_data)
        else:
            # Can't afford to continue
            stop_learning_language(character, learning_data["language"])
            print(character.name + " can't afford to continue learning " + learning_data["language"])

func complete_language_learning(character: Character, learning_data: Dictionary):
    """Complete learning a language"""
    var language = learning_data["language"]

    # Add language to character's known languages
    if language not in character.known_languages:
        character.known_languages.append(language)

    # Remove from learning progress
    var learning_key = character.name + "_" + language
    learning_progress.erase(learning_key)

    language_learned.emit(character, language)
    print(character.name + " learned " + language + "!")

func get_character_language_progress(character: Character) -> Dictionary:
    """Get language learning progress for a character"""
    var progress = {}

    for learning_key in learning_progress.keys():
        if learning_key.begins_with(character.name + "_"):
            var learning_data = learning_progress[learning_key]
            progress[learning_data["language"]] = learning_data["progress"]

    return progress

func get_character_by_name(name: String) -> Character:
    """Get character by name (placeholder - would use CharacterManager)"""
    # This would be implemented with proper character management
    return null

func get_language_difficulty_name(difficulty: int) -> String:
    """Get difficulty name for a language"""
    match difficulty:
        0: return "Trivial"
        1: return "Easy"
        2: return "Medium"
        3: return "Hard"
        4: return "Very Hard"
        _: return "Unknown"

func get_language_learning_time_remaining(character: Character, language: String) -> float:
    """Get remaining learning time for a language in days"""
    var learning_key = character.name + "_" + language
    if not learning_progress.has(learning_key):
        return 0.0

    var learning_data = learning_progress[learning_key]
    var remaining_progress = 1.0 - learning_data["progress"]
    var daily_progress = 1.0 / learning_data.get("total_days", 250)

    return remaining_progress / daily_progress

# YAML loading functions for language system
func load_language_data() -> void:
    """Load language data from YAML file"""
    var file_path = "res://data/languages.yaml"
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        print("Error: Could not open languages file: " + file_path)
        return

    var yaml_string = file.get_as_text()
    file.close()

    var language_config = parse_yaml_languages(yaml_string)
    if language_config == null:
        print("Error parsing languages YAML")
        return

    # Load language data
    var languages = language_config.get("languages", [])
    for language_data in languages:
        var language_id = language_data.get("id", "")
        if language_id != "":
            available_languages[language_id] = language_data

    # Load categories
    var categories = language_config.get("categories", {})
    if categories is Dictionary:
        for category_id in categories.keys():
            language_categories[category_id] = categories[category_id]
    else:
        print("Warning: categories is not a Dictionary, got: ", typeof(categories))

    # Load difficulty levels
    var difficulties = language_config.get("difficulty_levels", {})
    if difficulties is Dictionary:
        for difficulty_id in difficulties.keys():
            difficulty_levels[difficulty_id] = difficulties[difficulty_id]
    else:
        print("Warning: difficulty_levels is not a Dictionary, got: ", typeof(difficulties))

    print("Loaded " + str(available_languages.size()) + " languages")

func parse_yaml_languages(yaml_string: String) -> Dictionary:
    """Parse YAML language configuration"""
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
        elif line.begins_with("- ") and line_indent == 0:
            # Handle array items (languages)
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
