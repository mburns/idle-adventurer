extends Node

# Leveling system with difficult progression to level 20

class_name LevelingSystem

signal level_up(character: Character, new_level: int)
signal ability_score_increase(character: Character, ability: String, new_score: int)
signal class_feature_unlocked(character: Character, feature: String)

# Experience requirements for each level (exponential growth)
var level_requirements = {
    1: 0,
    2: 300,
    3: 900,
    4: 2700,
    5: 6500,
    6: 14000,
    7: 23000,
    8: 34000,
    9: 48000,
    10: 64000,
    11: 85000,
    12: 100000,
    13: 120000,
    14: 140000,
    15: 165000,
    16: 195000,
    17: 225000,
    18: 265000,
    19: 305000,
    20: 355000
}

# Class features by level (simplified for idle game)
var class_features = {
    "fighter": {
        1: ["Fighting Style", "Second Wind"],
        2: ["Action Surge"],
        3: ["Martial Archetype"],
        4: ["Ability Score Improvement"],
        5: ["Extra Attack"],
        6: ["Ability Score Improvement"],
        7: ["Martial Archetype Feature"],
        8: ["Ability Score Improvement"],
        9: ["Indomitable"],
        10: ["Martial Archetype Feature"],
        11: ["Extra Attack (2)"],
        12: ["Ability Score Improvement"],
        13: ["Indomitable (2 uses)"],
        14: ["Ability Score Improvement"],
        15: ["Martial Archetype Feature"],
        16: ["Ability Score Improvement"],
        17: ["Action Surge (2 uses)", "Indomitable (3 uses)"],
        18: ["Martial Archetype Feature"],
        19: ["Ability Score Improvement"],
        20: ["Extra Attack (3)"]
    },
    "wizard": {
        1: ["Spellcasting", "Arcane Recovery"],
        2: ["Arcane Tradition"],
        3: ["Ritual Casting"],
        4: ["Ability Score Improvement"],
        5: ["Arcane Tradition Feature"],
        6: ["Ability Score Improvement"],
        7: ["Arcane Tradition Feature"],
        8: ["Ability Score Improvement"],
        9: ["Arcane Tradition Feature"],
        10: ["Arcane Tradition Feature"],
        11: ["Arcane Tradition Feature"],
        12: ["Ability Score Improvement"],
        13: ["Arcane Tradition Feature"],
        14: ["Arcane Tradition Feature"],
        15: ["Arcane Tradition Feature"],
        16: ["Ability Score Improvement"],
        17: ["Arcane Tradition Feature"],
        18: ["Spell Mastery"],
        19: ["Ability Score Improvement"],
        20: ["Signature Spells"]
    },
    "rogue": {
        1: ["Expertise", "Sneak Attack", "Thieves' Cant"],
        2: ["Cunning Action"],
        3: ["Roguish Archetype"],
        4: ["Ability Score Improvement"],
        5: ["Uncanny Dodge"],
        6: ["Expertise", "Roguish Archetype Feature"],
        7: ["Evasion"],
        8: ["Ability Score Improvement"],
        9: ["Roguish Archetype Feature"],
        10: ["Ability Score Improvement"],
        11: ["Reliable Talent"],
        12: ["Ability Score Improvement"],
        13: ["Roguish Archetype Feature"],
        14: ["Blindsense"],
        15: ["Slippery Mind"],
        16: ["Ability Score Improvement"],
        17: ["Roguish Archetype Feature"],
        18: ["Elusive"],
        19: ["Ability Score Improvement"],
        20: ["Stroke of Luck"]
    },
    "cleric": {
        1: ["Spellcasting", "Divine Domain"],
        2: ["Channel Divinity", "Divine Domain Feature"],
        3: ["Divine Domain Feature"],
        4: ["Ability Score Improvement"],
        5: ["Destroy Undead"],
        6: ["Channel Divinity (2 uses)", "Divine Domain Feature"],
        7: ["Divine Domain Feature"],
        8: ["Ability Score Improvement", "Destroy Undead (CR 1)"],
        9: ["Divine Domain Feature"],
        10: ["Divine Intervention"],
        11: ["Destroy Undead (CR 2)"],
        12: ["Ability Score Improvement"],
        13: ["Divine Domain Feature"],
        14: ["Destroy Undead (CR 3)"],
        15: ["Divine Domain Feature"],
        16: ["Ability Score Improvement"],
        17: ["Destroy Undead (CR 4)", "Divine Domain Feature"],
        18: ["Channel Divinity (3 uses)"],
        19: ["Ability Score Improvement"],
        20: ["Divine Intervention Improvement"]
    },
    "ranger": {
        1: ["Favored Enemy", "Natural Explorer"],
        2: ["Fighting Style", "Spellcasting"],
        3: ["Ranger Archetype", "Primeval Awareness"],
        4: ["Ability Score Improvement"],
        5: ["Extra Attack"],
        6: ["Favored Enemy and Natural Explorer improvements"],
        7: ["Ranger Archetype Feature"],
        8: ["Ability Score Improvement", "Land's Stride"],
        9: ["Ranger Archetype Feature"],
        10: ["Natural Explorer improvement", "Hide in Plain Sight"],
        11: ["Ranger Archetype Feature"],
        12: ["Ability Score Improvement"],
        13: ["Favored Enemy improvement"],
        14: ["Favored Enemy improvement", "Vanish"],
        15: ["Ranger Archetype Feature"],
        16: ["Ability Score Improvement"],
        17: ["Ranger Archetype Feature"],
        18: ["Feral Senses"],
        19: ["Ability Score Improvement"],
        20: ["Foe Slayer"]
    }
}

var character_experience: Dictionary = {} # character_name -> total_experience

func _init():
    setup_leveling_system()

func setup_leveling_system():
    """Initialize the leveling system"""
    print("Leveling System initialized")

func add_experience(character: Character, amount: float):
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

func level_up_character(character: Character, new_level: int):
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

func apply_class_features(character: Character, level: int):
    """Apply class features for a level"""
    var character_class = character.character_class.to_lower()
    var features = class_features.get(character_class, {})
    var level_features = features.get(level, [])

    for feature in level_features:
        unlock_class_feature(character, feature)
        class_feature_unlocked.emit(character, feature)

func unlock_class_feature(character: Character, feature: String):
    """Unlock a specific class feature"""
    if not character.has_method("add_class_feature"):
        # Add to character's class features if the method exists
        print(character.name + " unlocked: " + feature)
    else:
        character.add_class_feature(feature)

func apply_ability_score_improvements(character: Character, level: int):
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

func update_hit_points(character: Character, new_level: int):
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
