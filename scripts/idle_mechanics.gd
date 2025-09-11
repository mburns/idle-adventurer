class_name IdleMechanics
extends Node

# Idle progression system for D&D activities

# Activity definitions
static var activities = {
    # Strength activities
    "Push a Rock": {
        "ability": "strength",
        "skill": "Athletics",
        "base_duration": 10.0, # 10 seconds for testing
        "base_xp": 10,
        "base_gold": 2,
        "description": "Push a heavy rock to build strength and endurance"
    },
    "Tip Over a Statue": {
        "ability": "strength",
        "skill": "Athletics",
        "base_duration": 10.0, # 10 seconds for testing
        "base_xp": 8,
        "base_gold": 1,
        "description": "Practice toppling statues to improve your strength"
    },
    "Lift Weights": {
        "ability": "strength",
        "skill": "Athletics",
        "base_duration": 10.0, # 10 seconds for testing
        "base_xp": 15,
        "base_gold": 3,
        "description": "Regular weight training to build muscle"
    },

    # Dexterity activities
    "Practice Acrobatics": {
        "ability": "dexterity",
        "skill": "Acrobatics",
        "base_duration": 240.0, # 4 minutes
        "base_xp": 12,
        "base_gold": 2,
        "description": "Practice flips, rolls, and acrobatic maneuvers"
    },
    "Pick Locks": {
        "ability": "dexterity",
        "skill": "Sleight of Hand",
        "base_duration": 180.0, # 3 minutes
        "base_xp": 10,
        "base_gold": 5,
        "description": "Practice lockpicking to improve dexterity"
    },
    "Stealth Training": {
        "ability": "dexterity",
        "skill": "Stealth",
        "base_duration": 300.0, # 5 minutes
        "base_xp": 12,
        "base_gold": 3,
        "description": "Practice moving silently and hiding"
    },
    "Play Instrument": {
        "ability": "dexterity",
        "skill": "Performance",
        "base_duration": 360.0, # 6 minutes
        "base_xp": 15,
        "base_gold": 8,
        "description": "Practice playing a musical instrument"
    },
    "Do a Kickflip": {
        "ability": "dexterity",
        "skill": "Acrobatics",
        "base_duration": 10.0, # 10 seconds for testing
        "base_xp": 12,
        "base_gold": 2,
        "description": "Practice kickflips to improve dexterity and acrobatics"
    },

    # Constitution activities
    "Hold Your Breath": {
        "ability": "constitution",
        "skill": "Constitution",
        "base_duration": 120.0, # 2 minutes
        "base_xp": 8,
        "base_gold": 1,
        "description": "Practice holding your breath to build endurance"
    },
    "Drink Ale": {
        "ability": "constitution",
        "skill": "Constitution",
        "base_duration": 60.0, # 1 minute
        "base_xp": 5,
        "base_gold": 3,
        "description": "Quaff ale to build tolerance and constitution"
    },
    "Endurance Training": {
        "ability": "constitution",
        "skill": "Constitution",
        "base_duration": 480.0, # 8 minutes
        "base_xp": 20,
        "base_gold": 4,
        "description": "Long-distance running and endurance exercises"
    },

    # Intelligence activities
    "Study Arcana": {
        "ability": "intelligence",
        "skill": "Arcana",
        "base_duration": 600.0, # 10 minutes
        "base_xp": 25,
        "base_gold": 5,
        "description": "Study magical theory and arcane knowledge"
    },
    "Research History": {
        "ability": "intelligence",
        "skill": "History",
        "base_duration": 480.0, # 8 minutes
        "base_xp": 20,
        "base_gold": 3,
        "description": "Research historical events and ancient knowledge"
    },
    "Investigate": {
        "ability": "intelligence",
        "skill": "Investigation",
        "base_duration": 360.0, # 6 minutes
        "base_xp": 15,
        "base_gold": 4,
        "description": "Practice deductive reasoning and investigation"
    },
    "Study Nature": {
        "ability": "intelligence",
        "skill": "Nature",
        "base_duration": 420.0, # 7 minutes
        "base_xp": 18,
        "base_gold": 2,
        "description": "Study natural phenomena and wildlife"
    },
    "Research Religion": {
        "ability": "intelligence",
        "skill": "Religion",
        "base_duration": 540.0, # 9 minutes
        "base_xp": 22,
        "base_gold": 4,
        "description": "Study religious texts and divine knowledge"
    },
    "Forge Document": {
        "ability": "intelligence",
        "skill": "Sleight of Hand",
        "base_duration": 300.0, # 5 minutes
        "base_xp": 12,
        "base_gold": 6,
        "description": "Practice creating convincing forgeries"
    },

    # Wisdom activities
    "Animal Handling": {
        "ability": "wisdom",
        "skill": "Animal Handling",
        "base_duration": 360.0, # 6 minutes
        "base_xp": 15,
        "base_gold": 3,
        "description": "Practice working with and training animals"
    },
    "Practice Insight": {
        "ability": "wisdom",
        "skill": "Insight",
        "base_duration": 240.0, # 4 minutes
        "base_xp": 10,
        "base_gold": 2,
        "description": "Practice reading people and understanding motivations"
    },
    "Study Medicine": {
        "ability": "wisdom",
        "skill": "Medicine",
        "base_duration": 480.0, # 8 minutes
        "base_xp": 20,
        "base_gold": 4,
        "description": "Study healing techniques and medical knowledge"
    },
    "Practice Perception": {
        "ability": "wisdom",
        "skill": "Perception",
        "base_duration": 300.0, # 5 minutes
        "base_xp": 12,
        "base_gold": 2,
        "description": "Practice noticing details and staying alert"
    },
    "Survival Training": {
        "ability": "wisdom",
        "skill": "Survival",
        "base_duration": 600.0, # 10 minutes
        "base_xp": 25,
        "base_gold": 5,
        "description": "Practice wilderness survival skills"
    },
    "Detect Undead": {
        "ability": "wisdom",
        "skill": "Religion",
        "base_duration": 180.0, # 3 minutes
        "base_xp": 8,
        "base_gold": 3,
        "description": "Practice sensing the presence of undead creatures"
    },

    # Charisma activities
    "Practice Deception": {
        "ability": "charisma",
        "skill": "Deception",
        "base_duration": 240.0, # 4 minutes
        "base_xp": 10,
        "base_gold": 3,
        "description": "Practice lying and misleading others"
    },
    "Practice Intimidation": {
        "ability": "charisma",
        "skill": "Intimidation",
        "base_duration": 180.0, # 3 minutes
        "base_xp": 8,
        "base_gold": 2,
        "description": "Practice threatening and intimidating others"
    },
    "Performance Practice": {
        "ability": "charisma",
        "skill": "Performance",
        "base_duration": 360.0, # 6 minutes
        "base_xp": 15,
        "base_gold": 8,
        "description": "Practice performing for audiences"
    },
    "Practice Persuasion": {
        "ability": "charisma",
        "skill": "Persuasion",
        "base_duration": 300.0, # 5 minutes
        "base_xp": 12,
        "base_gold": 4,
        "description": "Practice convincing others through diplomacy"
    },
    "Blend into Crowd": {
        "ability": "charisma",
        "skill": "Deception",
        "base_duration": 240.0, # 4 minutes
        "base_xp": 10,
        "base_gold": 2,
        "description": "Practice blending in with crowds and going unnoticed"
    },

    # Crafting activities
    "Blacksmithing": {
        "ability": "strength",
        "skill": "Crafting",
        "base_duration": 1800.0, # 30 minutes
        "base_xp": 20,
        "base_gold": 8,
        "description": "Craft weapons and armor using smith's tools"
    },
    "Jewelry Making": {
        "ability": "dexterity",
        "skill": "Crafting",
        "base_duration": 2400.0, # 40 minutes
        "base_xp": 25,
        "base_gold": 12,
        "description": "Craft delicate jewelry and precision items"
    },
    "Leatherworking": {
        "ability": "dexterity",
        "skill": "Crafting",
        "base_duration": 1200.0, # 20 minutes
        "base_xp": 15,
        "base_gold": 6,
        "description": "Craft leather armor and accessories"
    },
    "Pottery": {
        "ability": "intelligence",
        "skill": "Crafting",
        "base_duration": 1500.0, # 25 minutes
        "base_xp": 18,
        "base_gold": 5,
        "description": "Craft pottery and ceramic items"
    },
    "Weaving": {
        "ability": "dexterity",
        "skill": "Crafting",
        "base_duration": 1800.0, # 30 minutes
        "base_xp": 20,
        "base_gold": 7,
        "description": "Weave cloth and textiles"
    },
    "Woodworking": {
        "ability": "strength",
        "skill": "Crafting",
        "base_duration": 2100.0, # 35 minutes
        "base_xp": 22,
        "base_gold": 9,
        "description": "Craft wooden furniture and tools"
    },

    # Profession activities
    "Artisan": {
        "ability": "intelligence",
        "skill": "Profession",
        "base_duration": 3600.0, # 60 minutes
        "base_xp": 30,
        "base_gold": 15,
        "description": "Work as a skilled artisan, maintaining modest lifestyle"
    },
    "Merchant": {
        "ability": "charisma",
        "skill": "Profession",
        "base_duration": 4200.0, # 70 minutes
        "base_xp": 35,
        "base_gold": 20,
        "description": "Work as a merchant, trading goods and services"
    },
    "Scholar": {
        "ability": "intelligence",
        "skill": "Profession",
        "base_duration": 4800.0, # 80 minutes
        "base_xp": 40,
        "base_gold": 12,
        "description": "Work as a scholar, researching and teaching"
    },
    "Guard": {
        "ability": "strength",
        "skill": "Profession",
        "base_duration": 5400.0, # 90 minutes
        "base_xp": 25,
        "base_gold": 18,
        "description": "Work as a city guard, maintaining security"
    },
    "Priest": {
        "ability": "wisdom",
        "skill": "Profession",
        "base_duration": 3600.0, # 60 minutes
        "base_xp": 30,
        "base_gold": 10,
        "description": "Work as a priest, providing religious services"
    },
    "Entertainer": {
        "ability": "charisma",
        "skill": "Profession",
        "base_duration": 3000.0, # 50 minutes
        "base_xp": 35,
        "base_gold": 25,
        "description": "Work as an entertainer, supporting wealthy lifestyle"
    },

    # Training activities
    "Learn Language": {
        "ability": "intelligence",
        "skill": "Training",
        "base_duration": 14400.0, # 4 hours (250 days = 4 hours for testing)
        "base_xp": 50,
        "base_gold": - 250, # Costs 1 gp per day
        "description": "Learn a new language with an instructor"
    },
    "Tool Proficiency": {
        "ability": "intelligence",
        "skill": "Training",
        "base_duration": 14400.0, # 4 hours (250 days = 4 hours for testing)
        "base_xp": 50,
        "base_gold": - 250, # Costs 1 gp per day
        "description": "Gain proficiency with a new set of tools"
    },
    "Skill Training": {
        "ability": "intelligence",
        "skill": "Training",
        "base_duration": 14400.0, # 4 hours (250 days = 4 hours for testing)
        "base_xp": 50,
        "base_gold": - 250, # Costs 1 gp per day
        "description": "Train to gain proficiency in a new skill"
    },

    # Rest activities
    "Short Rest": {
        "ability": "constitution",
        "skill": "Constitution",
        "base_duration": 900.0, # 15 minutes
        "base_xp": 0,
        "base_gold": 0,
        "description": "Take a short rest to recover hit points and abilities"
    },
    "Long Rest": {
        "ability": "constitution",
        "skill": "Constitution",
        "base_duration": 28800.0, # 8 hours
        "base_xp": 0,
        "base_gold": 0,
        "description": "Take a long rest to fully recover"
    }
}

# Calculate activity duration based on character stats
static func calculate_activity_duration(activity_name: String, character: Character) -> float:
    var activity = activities.get(activity_name, {})
    if activity.is_empty():
        return 0.0

    var base_duration = activity.get("base_duration", 300.0)
    var ability = activity.get("ability", "strength")
    var ability_score = character.get(ability)
    var ability_modifier = character.get_ability_modifier(ability_score)

    # Reduce duration based on ability modifier (higher ability = faster completion)
    var duration_modifier = 1.0 - (ability_modifier * 0.05) # 5% reduction per point of modifier
    duration_modifier = max(0.5, duration_modifier) # Minimum 50% of base duration

    return base_duration * duration_modifier

# Calculate activity rewards based on character stats
static func calculate_activity_rewards(activity_name: String, character: Character) -> Dictionary:
    var activity = activities.get(activity_name, {})
    if activity.is_empty():
        return {"xp": 0, "gold": 0}

    var base_xp = activity.get("base_xp", 0)
    var base_gold = activity.get("base_gold", 0)
    var ability = activity.get("ability", "strength")
    var ability_score = character.get(ability)
    var ability_modifier = character.get_ability_modifier(ability_score)

    # Increase rewards based on ability modifier
    var xp_modifier = 1.0 + (ability_modifier * 0.1) # 10% increase per point of modifier
    var gold_modifier = 1.0 + (ability_modifier * 0.05) # 5% increase per point of modifier

    # Apply proficiency bonus if character is proficient in the skill
    var skill = activity.get("skill", "")
    if skill in character.skill_proficiencies:
        xp_modifier += 0.5 # 50% bonus for proficiency
        gold_modifier += 0.25 # 25% bonus for proficiency

    return {
        "xp": int(base_xp * xp_modifier),
        "gold": int(base_gold * gold_modifier)
    }

# Get all activities for a specific ability
static func get_activities_for_ability(ability: String) -> Array[String]:
    var result = []
    for activity_name in activities.keys():
        if activities[activity_name].get("ability", "") == ability:
            result.append(activity_name)
    return result

# Get activity data
static func get_activity(activity_name: String) -> Dictionary:
    return activities.get(activity_name, {})

# Get all activity names
static func get_all_activities() -> Array[String]:
    return activities.keys()

# Check if character can perform activity (has required proficiencies, etc.)
static func can_perform_activity(activity_name: String, character: Character) -> bool:
    var activity = activities.get(activity_name, {})
    if activity.is_empty():
        return false

    # Check if character is currently doing something else
    if character.current_activity != "":
        return false

    # Add other restrictions here (equipment, level requirements, etc.)
    return true

# Start an activity for a character
static func start_activity(activity_name: String, character: Character) -> bool:
    if not can_perform_activity(activity_name, character):
        return false

    var duration = calculate_activity_duration(activity_name, character)
    character.start_activity(activity_name, duration)
    return true

# Complete an activity and give rewards
static func complete_activity(character: Character) -> Dictionary:
    if character.current_activity == "":
        return {"xp": 0, "gold": 0}

    var rewards = calculate_activity_rewards(character.current_activity, character)

    # Give rewards to character
    character.add_experience(rewards.xp)
    character.add_gold(rewards.gold)

    # Complete the activity
    character.complete_activity()

    return rewards
