class_name Character
extends Resource

# Basic Character Information
@export var name: String = ""
@export var race: String = ""
@export var character_class: String = ""
@export var background: String = ""
@export var level: int = 1
@export var experience_points: int = 0
@export var height: int = 0 # Height in inches
@export var weight: int = 0 # Weight in pounds

# Ability Scores (generated when character is created)
@export var strength: int = 0
@export var dexterity: int = 0
@export var constitution: int = 0
@export var intelligence: int = 0
@export var wisdom: int = 0
@export var charisma: int = 0

# Derived Stats
@export var hit_points: int = 0
@export var max_hit_points: int = 0
@export var armor_class: int = 10
@export var proficiency_bonus: int = 2

# Proficiencies
@export var saving_throw_proficiencies: Array[String] = []
@export var skill_proficiencies: Array[String] = []

# Resources
@export var gold: int = 0  # Legacy gold property (for backward compatibility)
@export var currency: Dictionary = {"currencies": {}}  # Dynamic currency system
@export var spell_slots: Array[int] = []

# Race-derived
@export var size: String = "Medium"
@export var speed: int = 30
@export var racial_traits: Array[Dictionary] = [] # [{"name": String, "description": String}]

# Spells and buffs
@export var known_spells: Array[String] = []
@export var spellbook: Dictionary = {} # spell_name -> spell_data
@export var active_buffs: Array[Dictionary] = [] # [{"name": String, "expires_at": float}]

# Experience and progression
@export var strength_experience: float = 0.0
@export var dexterity_experience: float = 0.0
@export var constitution_experience: float = 0.0
@export var intelligence_experience: float = 0.0
@export var wisdom_experience: float = 0.0
@export var charisma_experience: float = 0.0
@export var known_languages: Array[String] = ["Common"] # Start with Common
@export var activity_progress: float = 0.0

# Proficiencies
@export var tool_proficiencies: Array[String] = []
@export var language_proficiencies: Array[String] = []
@export var weapon_proficiencies: Array[String] = []
@export var armor_proficiencies: Array[String] = []

# Equipment
@export var equipment: Dictionary = {}

# Current Activity
@export var current_activity: String = ""
@export var activity_start_time: float = 0.0
@export var activity_duration: float = 0.0

# Faction Reputation
@export var faction_reputation: Dictionary = {}

# Initialize character with default values
func _init() -> void:
    # Don't update derived stats here - they'll be set when ability scores are assigned
    pass

# Calculate ability score modifier (D&D 5e standard: (score - 10) / 2)
func get_ability_modifier(score: int) -> int:
    return floor((score - 10) / 2.0)

# Get all ability modifiers
func get_strength_modifier() -> int:
    return get_ability_modifier(strength)

func get_dexterity_modifier() -> int:
    return get_ability_modifier(dexterity)

func get_constitution_modifier() -> int:
    return get_ability_modifier(constitution)

func get_intelligence_modifier() -> int:
    return get_ability_modifier(intelligence)

func get_wisdom_modifier() -> int:
    return get_ability_modifier(wisdom)

func get_charisma_modifier() -> int:
    return get_ability_modifier(charisma)

# Update derived stats based on ability scores and level
func update_derived_stats() -> void:
    # Update proficiency bonus based on level (D&D 5e standard)
    proficiency_bonus = 2 + floor((level - 1) / 4.0)

    # Update hit points (simplified - would need class-specific calculation)
    var con_mod = get_constitution_modifier()
    max_hit_points = 8 + con_mod + ((level - 1) * (4 + con_mod))
    if hit_points == 0:
        hit_points = max_hit_points

    # Update armor class (simplified - would need equipment calculation)
    armor_class = 10 + get_dexterity_modifier()

# Add experience points and check for level up
func add_experience(amount: int) -> bool:
    experience_points += amount
    var old_level = level
    level = calculate_level_from_xp(experience_points)

    if level > old_level:
        level_up()
        return true
    return false

# Calculate level from experience points (D&D 5e standard)
func calculate_level_from_xp(xp: int) -> int:
    var xp_thresholds = [
        0, 300, 900, 2700, 6500, 14000, 23000, 34000, 48000, 64000,
        85000, 100000, 120000, 140000, 165000, 195000, 225000, 265000, 305000, 355000
    ]

    for i in range(xp_thresholds.size() - 1, -1, -1):
        if xp >= xp_thresholds[i]:
            return i + 1
    return 1

# Handle level up
func level_up() -> void:
    update_derived_stats()
    # TODO: Add class-specific level up features
    print("Level up! Now level ", level)

func apply_class_level_up_features() -> void:
    """Apply class-specific features when leveling up"""
    var class_features = load_class_features_for_level(character_class, level)
    if class_features.size() > 0:
        for feature in class_features:
            apply_class_feature(feature)
    else:
        print("No features found for ", character_class, " at level ", level)

func load_class_features_for_level(character_class_name: String, target_level: int) -> Array:
    """Load class features for a specific level from resource data"""
    # Use the class manager to get class data
    var class_manager = AutoloadManager.get_class_manager()
    if class_manager == null:
        print("Warning: Class manager not available")
        return []

    var class_data = class_manager.get_class_by_name(character_class_name)
    if class_data.is_empty():
        print("Warning: Could not find class data for: ", character_class_name)
        return []

    var level_features = class_data.get("level_features", {}).get(str(target_level), [])
    return level_features

func parse_class_yaml_for_level_features(yaml_content: String, target_level: int) -> Array:
    # This function is deprecated - now using resource manager
    print("Warning: parse_class_yaml_for_level_features is deprecated")
    return []

func apply_class_feature(feature_name: String) -> void:
    """Apply a specific class feature"""
    print(name, " gains ", feature_name, "!")

    # Apply any special effects based on feature name
    match feature_name.to_upper():
        "ABILITY SCORE IMPROVEMENT":
            # In a full implementation, this would open a UI for ability score selection
            print("Ability Score Improvement available - choose which ability to increase")
        "EXTRA ATTACK":
            print("You can now make an additional attack when taking the Attack action")
        "ACTION SURGE":
            print("You can take an additional action on your turn")
        "SPELL SLOTS":
            # Update spell slots based on class and level
            update_spell_slots_for_level()
        _:
            # Generic feature application
            print("Applied feature: ", feature_name)

func update_spell_slots_for_level() -> void:
    """Update spell slots based on class and level"""
    # This would be expanded to handle different spellcasting classes
    match character_class.to_upper():
        "WIZARD", "SORCERER", "WARLOCK":
            # Full casters get spell slots every level
            var new_slots = calculate_spell_slots_for_level(level)
            spell_slots = new_slots
        "CLERIC", "DRUID", "RANGER", "PALADIN":
            # Half casters get spell slots at certain levels
            if level >= 2:
                var new_slots = calculate_spell_slots_for_level(level)
                spell_slots = new_slots
        "BARD":
            # Bards are full casters
            var new_slots = calculate_spell_slots_for_level(level)
            spell_slots = new_slots

func calculate_spell_slots_for_level(target_level: int) -> Array:
    """Calculate spell slots for a given level"""
    # Simplified spell slot calculation
    # In a full implementation, this would use the official D&D spell slot table
    var slots = []

    if target_level >= 1:
        slots.append(2)  # 1st level slots
    if target_level >= 3:
        slots.append(2)  # 2nd level slots
    if target_level >= 5:
        slots.append(2)  # 3rd level slots
    if target_level >= 7:
        slots.append(1)  # 4th level slots
    if target_level >= 9:
        slots.append(1)  # 5th level slots

    return slots
# Spells API
func learn_spell(spell_name: String, spell_data: Dictionary = {}) -> void:
    if not (spell_name in known_spells):
        known_spells.append(spell_name)
    spellbook[spell_name] = spell_data

func forget_spell(spell_name: String) -> void:
    if spell_name in known_spells:
        known_spells.erase(spell_name)
    if spell_name in spellbook:
        spellbook.erase(spell_name)

# Buffs API
func add_buff(buff_name: String, duration_seconds: float) -> void:
    var expires_at = Time.get_unix_time_from_system() + duration_seconds
    active_buffs.append({"name": buff_name, "expires_at": expires_at})

func remove_expired_buffs() -> void:
    var now = Time.get_unix_time_from_system()
    active_buffs = active_buffs.filter(func(b): return b.get("expires_at", 0.0) > now)

# Start an activity
func start_activity(activity_name: String, duration: float) -> void:
    current_activity = activity_name
    activity_start_time = Time.get_unix_time_from_system()
    activity_duration = duration

# Check if current activity is complete
func is_activity_complete() -> bool:
    if current_activity == "":
        return false
    return (Time.get_unix_time_from_system() - activity_start_time) >= activity_duration

# Complete current activity
func complete_activity() -> void:
    if is_activity_complete():
        # TODO: Add activity-specific rewards
        current_activity = ""
        activity_start_time = 0.0
        activity_duration = 0.0

# Get time remaining for current activity
func get_activity_time_remaining() -> float:
    if current_activity == "":
        return 0.0
    var elapsed = Time.get_unix_time_from_system() - activity_start_time
    return max(0.0, activity_duration - elapsed)

# Add gold
func add_gold(amount: int) -> void:
    gold += amount

# Spend gold
func spend_gold(amount: int) -> bool:
    if gold >= amount:
        gold -= amount
        return true
    return false

# Get character summary
func get_summary() -> String:
    return "%s the %s %s (Level %d)" % [name, race, character_class, level]
