extends Node

# Preload required classes
const Character = preload("res://scripts/character.gd")
const DnDData = preload("res://scripts/dnd_data.gd")

# Singleton for managing the current character
var current_character: Character
var save_file_path = "user://character_save.dat"

# Signal emitted when character changes
signal character_changed(character: Character)
signal character_created(character: Character)
signal character_loaded(character: Character)

# Initialize with a default character
func _ready():
    if current_character == null:
        create_default_character()

# Create a new character with default values
func create_character(character_name: String, race: String, character_class: String, background: String) -> Character:
    var character = Character.new()
    character.name = character_name
    character.race = race
    character.character_class = character_class
    character.background = background

    # Apply race bonuses/traits
    apply_race_bonuses(character, race)
    apply_racial_traits(character, race)

    # Apply class features and starting spell slots
    apply_class_features(character, character_class)
    apply_starting_spell_slots(character, character_class)

    # Apply background features and starting equipment
    apply_background_features(character, background)
    assign_starting_equipment(character, character_class, background)

    # Update derived stats
    character.update_derived_stats()

    current_character = character
    character_created.emit(character)
    character_changed.emit(character)

    return character

# Create a default character for testing
func create_default_character() -> Character:
    return create_character("Bob", "Human", "Barbarian", "Folk Hero")

# Apply race bonuses to character
func apply_race_bonuses(character: Character, race: String):
    var race_data = DnDData.get_race(race)
    if race_data.is_empty():
        return

    var ability_increases = race_data.get("ability_increases", {})
    for ability in ability_increases.keys():
        var increase = ability_increases[ability]
        character.set(ability, character.get(ability) + increase)

    # Add languages
    var languages = race_data.get("languages", [])
    for language in languages:
        character.language_proficiencies.append(language)

    # Size and speed
    character.size = race_data.get("size", "Medium")
    character.speed = race_data.get("speed", 30)

func apply_racial_traits(character: Character, race: String):
    """Apply racial traits based on wiki data"""
    var races_data = WikiDataLoader.load_races_from_wiki()
    var race_data = races_data.get(race.to_lower(), {})
    if race_data.is_empty():
        print("No race data found for: " + race)
        return

    # Apply ability score increases
    apply_ability_score_increases(character, race_data)

    # Apply size and speed
    apply_size_and_speed(character, race_data)

    # Apply racial traits
    apply_racial_abilities(character, race_data)

    # Apply languages
    apply_racial_languages(character, race_data)

func apply_ability_score_increases(character: Character, race_data: Dictionary):
    """Apply ability score increases from race"""
    var traits = race_data.get("traits", [])

    for race_trait in traits:
        if race_trait.get("name", "").to_lower().find("ability score increase") != -1:
            var description = race_trait.get("description", "")

            # Parse ability score increases from description
            if "each increase by 1" in description:
                # Human: all abilities +1
                character.strength += 1
                character.dexterity += 1
                character.constitution += 1
                character.intelligence += 1
                character.wisdom += 1
                character.charisma += 1
            elif "Dexterity score increases by 2" in description:
                # Elf: Dexterity +2
                character.dexterity += 2
            elif "Intelligence score increases by 1" in description:
                # High Elf: Intelligence +1
                character.intelligence += 1
            # Add more parsing for other races as needed

func apply_size_and_speed(character: Character, race_data: Dictionary):
    """Apply size and speed from race"""
    var traits = race_data.get("traits", [])

    for race_trait in traits:
        var trait_name = race_trait.get("name", "").to_lower()
        var description = race_trait.get("description", "")

        if "size" in trait_name:
            if "medium" in description:
                character.size = "Medium"
            elif "small" in description:
                character.size = "Small"
            elif "large" in description:
                character.size = "Large"

        elif "speed" in trait_name:
            # Extract speed from description (e.g., "30 feet")
            var speed_match = RegEx.new()
            speed_match.compile("(\\d+) feet")
            var result = speed_match.search(description)
            if result:
                character.speed = result.get_string(1).to_int()

func apply_racial_abilities(character: Character, race_data: Dictionary):
    """Apply racial abilities and traits"""
    var traits = race_data.get("traits", [])
    var racial_abilities: Array[Dictionary] = []

    for race_trait in traits:
        var trait_name = race_trait.get("name", "")
        var description = race_trait.get("description", "")

        # Skip ability score increases, size, speed, and languages
        if "ability score increase" in trait_name.to_lower() or "size" in trait_name.to_lower() or "speed" in trait_name.to_lower() or "languages" in trait_name.to_lower():
            continue

        # Add racial trait
        racial_abilities.append({
            "name": trait_name,
            "description": description,
            "type": "racial"
        })

    character.racial_traits = racial_abilities

func apply_racial_languages(character: Character, race_data: Dictionary):
    """Apply racial languages"""
    var traits = race_data.get("traits", [])
    var known_languages = character.known_languages if character.has_method("get") and character.get("known_languages") != null else ["Common"]

    for race_trait in traits:
        var trait_name = race_trait.get("name", "").to_lower()
        var description = race_trait.get("description", "")

        if "languages" in trait_name:
            # Parse languages from description
            if "Common and Elvish" in description:
                if not "Elvish" in known_languages:
                    known_languages.append("Elvish")
            elif "Common and one extra language" in description:
                # Human gets Common + 1 choice
                # This would be handled in character creation UI
                pass
            # Add more language parsing as needed

    character.set("known_languages", known_languages)

# Apply class features to character
func apply_class_features(character: Character, class_type: String):
    var class_data = DnDData.get_class_data(class_type)
    if class_data.is_empty():
        return

    # Add skill proficiencies
    var skill_options = class_data.get("skill_options", [])
    var skill_choices = class_data.get("skill_choices", 0)

    # For now, just add the first few skills (in a real game, player would choose)
    for i in range(min(skill_choices, skill_options.size())):
        character.skill_proficiencies.append(skill_options[i])

    # Add armor proficiencies
    var armor_proficiencies = class_data.get("armor_proficiencies", [])
    for armor in armor_proficiencies:
        character.armor_proficiencies.append(armor)

    # Add weapon proficiencies
    var weapon_proficiencies = class_data.get("weapon_proficiencies", [])
    for weapon in weapon_proficiencies:
        character.weapon_proficiencies.append(weapon)

    # Add tool proficiencies
    var tool_proficiencies = class_data.get("tool_proficiencies", [])
    for tool in tool_proficiencies:
        character.tool_proficiencies.append(tool )

    # Saving throws
    var saving_throws = class_data.get("saving_throws", [])
    character.set("saving_throws", saving_throws)

func apply_starting_spell_slots(character: Character, class_type: String):
    var class_data = DnDData.get_class_data(class_type)
    if class_data.is_empty():
        return
    var slots = class_data.get("spell_slots_per_level", [])
    if slots.size() > 0:
        character.spell_slots = slots[0]

# Apply background features to character
func apply_background_features(character: Character, background: String):
    var background_data = DnDData.get_background(background)
    if background_data.is_empty():
        return

    # Add skill proficiencies
    var skill_proficiencies = background_data.get("skill_proficiencies", [])
    for skill in skill_proficiencies:
        character.skill_proficiencies.append(skill)

    # Add tool proficiencies
    var tool_proficiencies = background_data.get("tool_proficiencies", [])
    for tool in tool_proficiencies:
        character.tool_proficiencies.append(tool )

    # Add languages
    var languages = background_data.get("languages", [])
    for language in languages:
        character.language_proficiencies.append(language)

func assign_starting_equipment(character: Character, class_type: String, background: String):
    # Pull starting equipment from class (and background if applicable)
    var class_data = DnDData.get_class_data(class_type)
    if not class_data.is_empty():
        var starting_equipment = class_data.get("starting_equipment", {})
        for slot in starting_equipment.keys():
            var item = starting_equipment[slot]
            character.equipment[slot] = item

    var background_data = DnDData.get_background(background)
    if not background_data.is_empty():
        var bg_equipment = background_data.get("equipment", [])
        if not character.equipment.has("pack") and bg_equipment.size() > 0:
            character.equipment["pack"] = bg_equipment

# Save character to file
func save_character() -> bool:
    if current_character == null:
        return false

    var file = FileAccess.open(save_file_path, FileAccess.WRITE)
    if file == null:
        print("Error: Could not open save file for writing")
        return false

    # Convert character to dictionary for saving
    var character_data = {
        "name": current_character.name,
        "race": current_character.race,
        "character_class": current_character.character_class,
        "background": current_character.background,
        "level": current_character.level,
        "experience_points": current_character.experience_points,
        "strength": current_character.strength,
        "dexterity": current_character.dexterity,
        "constitution": current_character.constitution,
        "intelligence": current_character.intelligence,
        "wisdom": current_character.wisdom,
        "charisma": current_character.charisma,
        "hit_points": current_character.hit_points,
        "max_hit_points": current_character.max_hit_points,
        "armor_class": current_character.armor_class,
        "proficiency_bonus": current_character.proficiency_bonus,
        "gold": current_character.gold,
        "spell_slots": current_character.spell_slots,
        "skill_proficiencies": current_character.skill_proficiencies,
        "tool_proficiencies": current_character.tool_proficiencies,
        "language_proficiencies": current_character.language_proficiencies,
        "weapon_proficiencies": current_character.weapon_proficiencies,
        "armor_proficiencies": current_character.armor_proficiencies,
        "equipment": current_character.equipment,
        "current_activity": current_character.current_activity,
        "activity_start_time": current_character.activity_start_time,
        "activity_duration": current_character.activity_duration,
        "faction_reputation": current_character.faction_reputation,
        "size": current_character.size,
        "speed": current_character.speed,
        "racial_traits": current_character.racial_traits,
        "known_spells": current_character.known_spells,
        "spellbook": current_character.spellbook,
        "active_buffs": current_character.active_buffs
    }

    file.store_string(JSON.stringify(character_data))
    file.close()

    print("Character saved successfully")
    return true

# Load character from file
func load_character() -> bool:
    var file = FileAccess.open(save_file_path, FileAccess.READ)
    if file == null:
        print("No save file found")
        return false

    var json_string = file.get_as_text()
    file.close()

    var json = JSON.new()
    var parse_result = json.parse(json_string)
    if parse_result != OK:
        print("Error parsing save file: ", json.get_error_message())
        return false

    var character_data = json.get_data()
    if not character_data is Dictionary:
        print("Error: Save file does not contain valid character data")
        return false

    # Create new character and populate with saved data
    var character = Character.new()
    character.name = character_data.get("name", "")
    character.race = character_data.get("race", "")
    character.character_class = character_data.get("character_class", "")
    character.background = character_data.get("background", "")
    character.level = character_data.get("level", 1)
    character.experience_points = character_data.get("experience_points", 0)
    character.strength = character_data.get("strength", 10)
    character.dexterity = character_data.get("dexterity", 10)
    character.constitution = character_data.get("constitution", 10)
    character.intelligence = character_data.get("intelligence", 10)
    character.wisdom = character_data.get("wisdom", 10)
    character.charisma = character_data.get("charisma", 10)
    character.hit_points = character_data.get("hit_points", 0)
    character.max_hit_points = character_data.get("max_hit_points", 0)
    character.armor_class = character_data.get("armor_class", 10)
    character.proficiency_bonus = character_data.get("proficiency_bonus", 2)
    character.gold = character_data.get("gold", 0)
    character.spell_slots = []
    character.skill_proficiencies = character_data.get("skill_proficiencies", [])
    character.tool_proficiencies = character_data.get("tool_proficiencies", [])
    character.language_proficiencies = character_data.get("language_proficiencies", [])
    character.weapon_proficiencies = character_data.get("weapon_proficiencies", [])
    character.armor_proficiencies = character_data.get("armor_proficiencies", [])
    character.equipment = character_data.get("equipment", {})
    character.current_activity = character_data.get("current_activity", "")
    character.activity_start_time = character_data.get("activity_start_time", 0.0)
    character.activity_duration = character_data.get("activity_duration", 0.0)
    character.faction_reputation = character_data.get("faction_reputation", {})
    character.size = character_data.get("size", "Medium")
    character.speed = character_data.get("speed", 30)
    character.racial_traits = character_data.get("racial_traits", [])
    character.known_spells = character_data.get("known_spells", [])
    character.spellbook = character_data.get("spellbook", {})
    character.active_buffs = character_data.get("active_buffs", [])

    current_character = character
    character_loaded.emit(character)
    character_changed.emit(character)

    print("Character loaded successfully")
    return true

func apply_starting_equipment(character: Character, class_type: String, background: String):
    """Add starting equipment to character inventory"""
    # Add basic starting items
    add_starting_items(character, class_type)

    # Add class-specific equipment
    var class_data = WikiDataLoader.load_class_from_wiki(class_type)
    var equipment_list = class_data.get("starting_equipment", [])

    for item_name in equipment_list:
        var item_data = create_item_from_name(item_name)
        if item_data:
            add_item_to_character(character, item_data)

func add_starting_items(character: Character, class_type: String):
    """Add basic starting items to character inventory"""
    var inventory_system = get_inventory_system()

    # Basic items all characters start with
    var basic_items = [
        {
            "id": "backpack",
            "name": "Backpack",
            "type": "adventuring_gear",
            "description": "A backpack for carrying equipment",
            "weight": 5.0,
            "value": 2.0,
            "rarity": "common"
        },
        {
            "id": "bedroll",
            "name": "Bedroll",
            "type": "adventuring_gear",
            "description": "A bedroll for sleeping",
            "weight": 7.0,
            "value": 1.0,
            "rarity": "common"
        },
        {
            "id": "rations",
            "name": "Rations (1 day)",
            "type": "food",
            "description": "One day's worth of food",
            "weight": 2.0,
            "value": 0.5,
            "rarity": "common"
        },
        {
            "id": "waterskin",
            "name": "Waterskin",
            "type": "adventuring_gear",
            "description": "A container for water",
            "weight": 5.0,
            "value": 2.0,
            "rarity": "common"
        },
        {
            "id": "torch",
            "name": "Torch",
            "type": "adventuring_gear",
            "description": "A torch that burns for 1 hour",
            "weight": 1.0,
            "value": 0.01,
            "rarity": "common"
        }
    ]

    # Add basic items
    for item in basic_items:
        inventory_system.add_item(character, item, 1)

    # Add class-specific starting items
    match class_type.to_lower():
        "fighter":
            add_fighter_starting_items(character)
        "wizard":
            add_wizard_starting_items(character)
        "rogue":
            add_rogue_starting_items(character)
        "cleric":
            add_cleric_starting_items(character)
        "ranger":
            add_ranger_starting_items(character)

func add_fighter_starting_items(character: Character):
    """Add fighter-specific starting items"""
    var inventory_system = get_inventory_system()

    var fighter_items = [
        {
            "id": "chain_mail",
            "name": "Chain Mail",
            "type": "armor",
            "description": "Heavy armor that provides good protection",
            "weight": 55.0,
            "value": 75.0,
            "rarity": "common",
            "armor_class": 16
        },
        {
            "id": "shield",
            "name": "Shield",
            "type": "armor",
            "description": "A shield that provides +2 AC",
            "weight": 6.0,
            "value": 10.0,
            "rarity": "common",
            "armor_class_bonus": 2
        },
        {
            "id": "longsword",
            "name": "Longsword",
            "type": "weapon",
            "description": "A versatile melee weapon",
            "weight": 3.0,
            "value": 15.0,
            "rarity": "common",
            "damage": "1d8 slashing"
        }
    ]

    for item in fighter_items:
        inventory_system.add_item(character, item, 1)

func add_wizard_starting_items(character: Character):
    """Add wizard-specific starting items"""
    var inventory_system = get_inventory_system()

    var wizard_items = [
        {
            "id": "spellbook",
            "name": "Spellbook",
            "type": "tool",
            "description": "A book for recording spells",
            "weight": 3.0,
            "value": 50.0,
            "rarity": "common"
        },
        {
            "id": "component_pouch",
            "name": "Component Pouch",
            "type": "tool",
            "description": "A pouch for spell components",
            "weight": 2.0,
            "value": 25.0,
            "rarity": "common"
        },
        {
            "id": "quarterstaff",
            "name": "Quarterstaff",
            "type": "weapon",
            "description": "A simple melee weapon",
            "weight": 4.0,
            "value": 0.2,
            "rarity": "common",
            "damage": "1d6 bludgeoning"
        }
    ]

    for item in wizard_items:
        inventory_system.add_item(character, item, 1)

func add_rogue_starting_items(character: Character):
    """Add rogue-specific starting items"""
    var inventory_system = get_inventory_system()

    var rogue_items = [
        {
            "id": "leather_armor",
            "name": "Leather Armor",
            "type": "armor",
            "description": "Light armor that doesn't restrict movement",
            "weight": 10.0,
            "value": 10.0,
            "rarity": "common",
            "armor_class": 11
        },
        {
            "id": "thieves_tools",
            "name": "Thieves' Tools",
            "type": "tool",
            "description": "A set of tools for picking locks and disarming traps",
            "weight": 1.0,
            "value": 25.0,
            "rarity": "common"
        },
        {
            "id": "shortsword",
            "name": "Shortsword",
            "type": "weapon",
            "description": "A light, finesse weapon",
            "weight": 2.0,
            "value": 10.0,
            "rarity": "common",
            "damage": "1d6 piercing"
        }
    ]

    for item in rogue_items:
        inventory_system.add_item(character, item, 1)

func add_cleric_starting_items(character: Character):
    """Add cleric-specific starting items"""
    var inventory_system = get_inventory_system()

    var cleric_items = [
        {
            "id": "scale_mail",
            "name": "Scale Mail",
            "type": "armor",
            "description": "Medium armor with good protection",
            "weight": 45.0,
            "value": 50.0,
            "rarity": "common",
            "armor_class": 14
        },
        {
            "id": "shield",
            "name": "Shield",
            "type": "armor",
            "description": "A shield that provides +2 AC",
            "weight": 6.0,
            "value": 10.0,
            "rarity": "common",
            "armor_class_bonus": 2
        },
        {
            "id": "mace",
            "name": "Mace",
            "type": "weapon",
            "description": "A simple melee weapon",
            "weight": 4.0,
            "value": 5.0,
            "rarity": "common",
            "damage": "1d6 bludgeoning"
        }
    ]

    for item in cleric_items:
        inventory_system.add_item(character, item, 1)

func add_ranger_starting_items(character: Character):
    """Add ranger-specific starting items"""
    var inventory_system = get_inventory_system()

    var ranger_items = [
        {
            "id": "leather_armor",
            "name": "Leather Armor",
            "type": "armor",
            "description": "Light armor that doesn't restrict movement",
            "weight": 10.0,
            "value": 10.0,
            "rarity": "common",
            "armor_class": 11
        },
        {
            "id": "longbow",
            "name": "Longbow",
            "type": "weapon",
            "description": "A powerful ranged weapon",
            "weight": 2.0,
            "value": 50.0,
            "rarity": "common",
            "damage": "1d8 piercing"
        },
        {
            "id": "arrow",
            "name": "Arrow",
            "type": "ammunition",
            "description": "Ammunition for bows",
            "weight": 0.05,
            "value": 0.05,
            "rarity": "common"
        }
    ]

    for item in ranger_items:
        if item["id"] == "arrow":
            inventory_system.add_item(character, item, 20) # 20 arrows
        else:
            inventory_system.add_item(character, item, 1)

func create_item_from_name(item_name: String) -> Dictionary:
    """Create item data from item name"""
    # This would be expanded to handle all D&D items
    # For now, return basic item data
    return {
        "id": item_name.to_lower().replace(" ", "_"),
        "name": item_name,
        "type": "misc",
        "description": "A " + item_name.to_lower(),
        "weight": 1.0,
        "value": 1.0,
        "rarity": "common"
    }

func add_item_to_character(character: Character, item_data: Dictionary):
    """Add item to character's inventory"""
    var inventory_system = get_inventory_system()
    inventory_system.add_item(character, item_data, 1)

func get_inventory_system() -> InventorySystem:
    """Get the inventory system instance"""
    # This would be implemented with proper singleton management
    return InventorySystem.new()

# Check if save file exists
func has_save_file() -> bool:
    return FileAccess.file_exists(save_file_path)

# Delete save file
func delete_save_file() -> bool:
    if has_save_file():
        var dir = DirAccess.open("user://")
        return dir.remove(save_file_path) == OK
    return false

# Get current character
func get_current_character() -> Character:
    return current_character

# Set current character
func set_current_character(character: Character):
    current_character = character
    character_changed.emit(character)
