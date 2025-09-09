extends Node

# Language learning system for D&D idle game

class_name LanguageSystem

signal language_learned(character: Character, language: String)
signal language_progress(character: Character, language: String, progress: float)

# All available languages in D&D
var available_languages = {
    "Common": {
        "name": "Common",
        "description": "The most widely spoken language",
        "difficulty": 0,
        "learning_time_days": 0, # Already known
        "cost_per_day": 0.0
    },
    "Dwarvish": {
        "name": "Dwarvish",
        "description": "The language of dwarves",
        "difficulty": 1,
        "learning_time_days": 250,
        "cost_per_day": 1.0
    },
    "Elvish": {
        "name": "Elvish",
        "description": "The language of elves",
        "difficulty": 1,
        "learning_time_days": 250,
        "cost_per_day": 1.0
    },
    "Giant": {
        "name": "Giant",
        "description": "The language of giants and ogres",
        "difficulty": 2,
        "learning_time_days": 300,
        "cost_per_day": 1.5
    },
    "Gnomish": {
        "name": "Gnomish",
        "description": "The language of gnomes",
        "difficulty": 1,
        "learning_time_days": 250,
        "cost_per_day": 1.0
    },
    "Goblin": {
        "name": "Goblin",
        "description": "The language of goblins and hobgoblins",
        "difficulty": 1,
        "learning_time_days": 200,
        "cost_per_day": 0.8
    },
    "Halfling": {
        "name": "Halfling",
        "description": "The language of halflings",
        "difficulty": 1,
        "learning_time_days": 200,
        "cost_per_day": 0.8
    },
    "Orc": {
        "name": "Orc",
        "description": "The language of orcs",
        "difficulty": 1,
        "learning_time_days": 200,
        "cost_per_day": 0.8
    },
    "Abyssal": {
        "name": "Abyssal",
        "description": "The language of demons",
        "difficulty": 3,
        "learning_time_days": 400,
        "cost_per_day": 2.0
    },
    "Celestial": {
        "name": "Celestial",
        "description": "The language of angels",
        "difficulty": 3,
        "learning_time_days": 400,
        "cost_per_day": 2.0
    },
    "Draconic": {
        "name": "Draconic",
        "description": "The language of dragons",
        "difficulty": 3,
        "learning_time_days": 400,
        "cost_per_day": 2.0
    },
    "Deep Speech": {
        "name": "Deep Speech",
        "description": "The language of aberrations",
        "difficulty": 4,
        "learning_time_days": 500,
        "cost_per_day": 3.0
    },
    "Infernal": {
        "name": "Infernal",
        "description": "The language of devils",
        "difficulty": 3,
        "learning_time_days": 400,
        "cost_per_day": 2.0
    },
    "Primordial": {
        "name": "Primordial",
        "description": "The language of elementals",
        "difficulty": 2,
        "learning_time_days": 300,
        "cost_per_day": 1.5
    },
    "Sylvan": {
        "name": "Sylvan",
        "description": "The language of fey creatures",
        "difficulty": 2,
        "learning_time_days": 300,
        "cost_per_day": 1.5
    },
    "Undercommon": {
        "name": "Undercommon",
        "description": "The language of the Underdark",
        "difficulty": 2,
        "learning_time_days": 300,
        "cost_per_day": 1.5
    }
}

var learning_progress: Dictionary = {} # character_name -> {language: progress}

func _init():
    setup_language_system()

func setup_language_system():
    """Initialize the language learning system"""
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
