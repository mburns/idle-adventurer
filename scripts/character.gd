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

# Ability Scores
@export var strength: int = 10
@export var dexterity: int = 10
@export var constitution: int = 10
@export var intelligence: int = 10
@export var wisdom: int = 10
@export var charisma: int = 10

# Derived Stats
@export var hit_points: int = 0
@export var max_hit_points: int = 0
@export var armor_class: int = 10
@export var proficiency_bonus: int = 2

# Resources
@export var gold: int = 0
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
@export var skill_proficiencies: Array[String] = []
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
    update_derived_stats()

# Calculate ability score modifier
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
    # Update proficiency bonus based on level
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

# Calculate level from experience points
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
