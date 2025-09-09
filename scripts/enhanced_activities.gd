extends Node

# Enhanced activities system with multiple activities per ability score
# Based on D&D 5e rules and idle game mechanics

class_name EnhancedActivities

signal activity_started(activity: String, character: Character, ability: String)
signal activity_completed(activity: String, character: Character, rewards: Dictionary)
signal activity_progress(activity: String, character: Character, progress: float)

# Activity categories by ability score
var strength_activities = {
    "athletics_training": {
        "name": "Athletics Training",
        "description": "Practice climbing, jumping, and swimming",
        "daily_progress": 0.1, # 10% per day
        "cost_per_day": 0.5, # 5 sp per day
        "rewards": {"athletics_skill": 1, "strength_exp": 10},
        "requirements": {"strength": 10}
    },
    "physical_labor": {
        "name": "Physical Labor",
        "description": "Construction, mining, or heavy lifting work",
        "daily_progress": 0.15,
        "cost_per_day": 0.0, # Earns money instead
        "rewards": {"gold": 2, "strength_exp": 15, "constitution_exp": 5},
        "requirements": {"strength": 12}
    },
    "combat_training": {
        "name": "Combat Training",
        "description": "Weapon practice and sparring",
        "daily_progress": 0.08,
        "cost_per_day": 1.0,
        "rewards": {"weapon_proficiency": 1, "strength_exp": 12},
        "requirements": {"strength": 13, "gold": 50}
    },
    "blacksmithing": {
        "name": "Blacksmithing",
        "description": "Craft weapons and armor",
        "daily_progress": 0.05, # 5 gp per day (D&D rules)
        "cost_per_day": 0.0, # Materials cost handled separately
        "rewards": {"crafting_skill": 1, "strength_exp": 8, "gold": 5},
        "requirements": {"strength": 11, "tools": "smith_tools"}
    }
}

var dexterity_activities = {
    "acrobatics_practice": {
        "name": "Acrobatics Practice",
        "description": "Balance, tumbling, and flexibility training",
        "daily_progress": 0.12,
        "cost_per_day": 0.3,
        "rewards": {"acrobatics_skill": 1, "dexterity_exp": 12},
        "requirements": {"dexterity": 10}
    },
    "sleight_of_hand": {
        "name": "Sleight of Hand Practice",
        "description": "Pickpocketing and lockpicking training",
        "daily_progress": 0.1,
        "cost_per_day": 0.2,
        "rewards": {"sleight_of_hand_skill": 1, "dexterity_exp": 10},
        "requirements": {"dexterity": 12}
    },
    "stealth_training": {
        "name": "Stealth Training",
        "description": "Hiding, sneaking, and camouflage practice",
        "daily_progress": 0.08,
        "cost_per_day": 0.1,
        "rewards": {"stealth_skill": 1, "dexterity_exp": 8},
        "requirements": {"dexterity": 11}
    },
    "jewelry_making": {
        "name": "Jewelry Making",
        "description": "Craft delicate jewelry and precision items",
        "daily_progress": 0.06,
        "cost_per_day": 0.0,
        "rewards": {"crafting_skill": 1, "dexterity_exp": 10, "gold": 8},
        "requirements": {"dexterity": 13, "tools": "jeweler_tools"}
    },
    "performance_arts": {
        "name": "Performance Arts",
        "description": "Dancing, juggling, and entertainment",
        "daily_progress": 0.1,
        "cost_per_day": 0.0,
        "rewards": {"performance_skill": 1, "dexterity_exp": 8, "gold": 3},
        "requirements": {"dexterity": 10}
    }
}

var intelligence_activities = {
    "arcana_research": {
        "name": "Arcana Research",
        "description": "Study magic, spells, and magical theory",
        "daily_progress": 0.07,
        "cost_per_day": 1.0,
        "rewards": {"arcana_skill": 1, "intelligence_exp": 15, "spell_knowledge": 1},
        "requirements": {"intelligence": 13, "gold": 100}
    },
    "history_study": {
        "name": "History Study",
        "description": "Research past events and ancient civilizations",
        "daily_progress": 0.08,
        "cost_per_day": 0.5,
        "rewards": {"history_skill": 1, "intelligence_exp": 12},
        "requirements": {"intelligence": 11}
    },
    "investigation_work": {
        "name": "Investigation Work",
        "description": "Detective work and puzzle solving",
        "daily_progress": 0.09,
        "cost_per_day": 0.3,
        "rewards": {"investigation_skill": 1, "intelligence_exp": 10},
        "requirements": {"intelligence": 12}
    },
    "nature_study": {
        "name": "Nature Study",
        "description": "Study plants, animals, and natural phenomena",
        "daily_progress": 0.1,
        "cost_per_day": 0.2,
        "rewards": {"nature_skill": 1, "intelligence_exp": 8},
        "requirements": {"intelligence": 10}
    },
    "religion_study": {
        "name": "Religion Study",
        "description": "Study theology and divine lore",
        "daily_progress": 0.08,
        "cost_per_day": 0.4,
        "rewards": {"religion_skill": 1, "intelligence_exp": 10},
        "requirements": {"intelligence": 11}
    },
    "academic_work": {
        "name": "Academic Work",
        "description": "Teaching, writing, and research",
        "daily_progress": 0.06,
        "cost_per_day": 0.0,
        "rewards": {"intelligence_exp": 12, "gold": 4, "reputation": 1},
        "requirements": {"intelligence": 14}
    },
    "alchemy": {
        "name": "Alchemy",
        "description": "Brew potions and study magical substances",
        "daily_progress": 0.05,
        "cost_per_day": 0.0,
        "rewards": {"alchemy_skill": 1, "intelligence_exp": 15, "potions": 1},
        "requirements": {"intelligence": 13, "tools": "alchemist_supplies"}
    }
}

var wisdom_activities = {
    "animal_handling": {
        "name": "Animal Handling",
        "description": "Train animals and practice veterinary skills",
        "daily_progress": 0.1,
        "cost_per_day": 0.3,
        "rewards": {"animal_handling_skill": 1, "wisdom_exp": 10},
        "requirements": {"wisdom": 11}
    },
    "insight_practice": {
        "name": "Insight Practice",
        "description": "People watching and psychology study",
        "daily_progress": 0.08,
        "cost_per_day": 0.1,
        "rewards": {"insight_skill": 1, "wisdom_exp": 8},
        "requirements": {"wisdom": 10}
    },
    "medicine_practice": {
        "name": "Medicine Practice",
        "description": "Healing practice and medical research",
        "daily_progress": 0.09,
        "cost_per_day": 0.5,
        "rewards": {"medicine_skill": 1, "wisdom_exp": 12},
        "requirements": {"wisdom": 12}
    },
    "perception_training": {
        "name": "Perception Training",
        "description": "Awareness exercises and sensory training",
        "daily_progress": 0.11,
        "cost_per_day": 0.2,
        "rewards": {"perception_skill": 1, "wisdom_exp": 10},
        "requirements": {"wisdom": 10}
    },
    "survival_skills": {
        "name": "Survival Skills",
        "description": "Foraging, tracking, and wilderness survival",
        "daily_progress": 0.1,
        "cost_per_day": 0.0,
        "rewards": {"survival_skill": 1, "wisdom_exp": 8, "materials": 1},
        "requirements": {"wisdom": 11}
    },
    "spiritual_practices": {
        "name": "Spiritual Practices",
        "description": "Meditation and religious devotion",
        "daily_progress": 0.06,
        "cost_per_day": 0.0,
        "rewards": {"wisdom_exp": 6, "spiritual_insight": 1},
        "requirements": {"wisdom": 10}
    }
}

var charisma_activities = {
    "performance": {
        "name": "Performance",
        "description": "Music, acting, storytelling, and entertainment",
        "daily_progress": 0.1,
        "cost_per_day": 0.0,
        "rewards": {"performance_skill": 1, "charisma_exp": 12, "gold": 4},
        "requirements": {"charisma": 12}
    },
    "deception_practice": {
        "name": "Deception Practice",
        "description": "Acting, disguise, and social manipulation",
        "daily_progress": 0.08,
        "cost_per_day": 0.2,
        "rewards": {"deception_skill": 1, "charisma_exp": 10},
        "requirements": {"charisma": 11}
    },
    "intimidation_training": {
        "name": "Intimidation Training",
        "description": "Leadership and commanding presence",
        "daily_progress": 0.09,
        "cost_per_day": 0.3,
        "rewards": {"intimidation_skill": 1, "charisma_exp": 8},
        "requirements": {"charisma": 13}
    },
    "persuasion_practice": {
        "name": "Persuasion Practice",
        "description": "Negotiation, diplomacy, and public speaking",
        "daily_progress": 0.1,
        "cost_per_day": 0.1,
        "rewards": {"persuasion_skill": 1, "charisma_exp": 10},
        "requirements": {"charisma": 11}
    },
    "social_networking": {
        "name": "Social Networking",
        "description": "Building relationships and reputation",
        "daily_progress": 0.07,
        "cost_per_day": 1.0,
        "rewards": {"charisma_exp": 8, "reputation": 2, "connections": 1},
        "requirements": {"charisma": 12, "gold": 50}
    },
    "entertainment_business": {
        "name": "Entertainment Business",
        "description": "Running taverns and organizing events",
        "daily_progress": 0.05,
        "cost_per_day": 0.0,
        "rewards": {"charisma_exp": 15, "gold": 10, "reputation": 3},
        "requirements": {"charisma": 14, "gold": 200}
    }
}

var constitution_activities = {
    "endurance_training": {
        "name": "Endurance Training",
        "description": "Long-distance running and stamina building",
        "daily_progress": 0.12,
        "cost_per_day": 0.1,
        "rewards": {"constitution_exp": 15, "hit_points": 1},
        "requirements": {"constitution": 12}
    },
    "fasting_meditation": {
        "name": "Fasting & Meditation",
        "description": "Spiritual endurance and self-discipline",
        "daily_progress": 0.08,
        "cost_per_day": 0.0,
        "rewards": {"constitution_exp": 10, "wisdom_exp": 5, "spiritual_insight": 1},
        "requirements": {"constitution": 13, "wisdom": 11}
    },
    "physical_conditioning": {
        "name": "Physical Conditioning",
        "description": "General fitness and health maintenance",
        "daily_progress": 0.1,
        "cost_per_day": 0.2,
        "rewards": {"constitution_exp": 12, "hit_points": 1},
        "requirements": {"constitution": 10}
    },
    "resistance_training": {
        "name": "Resistance Training",
        "description": "Building immunity and poison resistance",
        "daily_progress": 0.06,
        "cost_per_day": 0.5,
        "rewards": {"constitution_exp": 8, "poison_resistance": 1},
        "requirements": {"constitution": 14, "gold": 100}
    }
}

# Non-ability specific activities
var general_activities = {
    "travel": {
        "name": "Travel",
        "description": "Explore new locations and discover places",
        "daily_progress": 0.15,
        "cost_per_day": 1.0,
        "rewards": {"exploration_exp": 20, "locations_discovered": 1},
        "requirements": {"gold": 10}
    },
    "faction_work": {
        "name": "Faction Work",
        "description": "Complete faction missions and build reputation",
        "daily_progress": 0.1,
        "cost_per_day": 0.0,
        "rewards": {"faction_reputation": 5, "gold": 3, "connections": 1},
        "requirements": {"faction_member": true}
    },
    "social_events": {
        "name": "Social Events",
        "description": "Attend parties and make connections",
        "daily_progress": 0.08,
        "cost_per_day": 2.0,
        "rewards": {"charisma_exp": 5, "connections": 2, "reputation": 1},
        "requirements": {"charisma": 10, "gold": 20}
    },
    "rest_recovery": {
        "name": "Rest & Recovery",
        "description": "Healing, relaxation, and mental health",
        "daily_progress": 0.2,
        "cost_per_day": 0.5,
        "rewards": {"hit_points": 5, "mental_health": 1},
        "requirements": {}
    },
    "shopping": {
        "name": "Shopping",
        "description": "Equipment acquisition and market research",
        "daily_progress": 0.1,
        "cost_per_day": 0.0,
        "rewards": {"equipment_knowledge": 1, "gold": - 5},
        "requirements": {"gold": 10}
    },
    "gambling": {
        "name": "Gambling",
        "description": "Games of chance and risk-taking",
        "daily_progress": 0.05,
        "cost_per_day": 0.0,
        "rewards": {"gold": 0, "charisma_exp": 3}, # Variable gold
        "requirements": {"charisma": 10, "gold": 5}
    },
    "religious_services": {
        "name": "Religious Services",
        "description": "Attend ceremonies and spiritual growth",
        "daily_progress": 0.06,
        "cost_per_day": 0.1,
        "rewards": {"wisdom_exp": 5, "spiritual_insight": 1},
        "requirements": {"wisdom": 9}
    }
}

var active_activities: Dictionary = {} # character_id -> activity_data

func _init():
    setup_activity_system()

func setup_activity_system():
    """Initialize the enhanced activities system"""
    var timer = Timer.new()
    timer.wait_time = 1.0 # Check every second
    timer.timeout.connect(_process_activities)
    timer.autostart = true
    add_child(timer)

func get_activities_for_ability(ability: String) -> Dictionary:
    """Get all activities for a specific ability score"""
    match ability.to_lower():
        "strength":
            return strength_activities
        "dexterity":
            return dexterity_activities
        "intelligence":
            return intelligence_activities
        "wisdom":
            return wisdom_activities
        "charisma":
            return charisma_activities
        "constitution":
            return constitution_activities
        "general":
            return general_activities
        _:
            return {}

func get_all_activities() -> Dictionary:
    """Get all available activities organized by ability"""
    return {
        "strength": strength_activities,
        "dexterity": dexterity_activities,
        "intelligence": intelligence_activities,
        "wisdom": wisdom_activities,
        "charisma": charisma_activities,
        "constitution": constitution_activities,
        "general": general_activities
    }

func can_start_activity(character: Character, activity_id: String, ability: String) -> bool:
    """Check if character can start a specific activity"""
    var activities = get_activities_for_ability(ability)
    if not activities.has(activity_id):
        return false

    var activity = activities[activity_id]
    var requirements = activity.get("requirements", {})

    # Check ability requirements
    for req_ability in requirements.keys():
        if req_ability in ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]:
            if character.get(req_ability) < requirements[req_ability]:
                return false

    # Check gold requirements
    if requirements.has("gold") and character.gold < requirements["gold"]:
        return false

    # Check tool requirements
    if requirements.has("tools"):
        # This would check if character has the required tools
        # For now, assume they do if they have enough gold
        if character.gold < 50: # Tool cost estimate
            return false

    # Check faction requirements
    if requirements.has("faction_member") and requirements["faction_member"]:
        # This would check if character is a faction member
        # For now, assume they are
        pass

    return true

func start_activity(character: Character, activity_id: String, ability: String):
    """Start a new activity for a character"""
    if not can_start_activity(character, activity_id, ability):
        print("Character cannot start activity: " + activity_id)
        return false

    var activities = get_activities_for_ability(ability)
    var activity = activities[activity_id]

    var activity_data = {
        "id": activity_id,
        "name": activity["name"],
        "ability": ability,
        "description": activity["description"],
        "daily_progress": activity["daily_progress"],
        "cost_per_day": activity["cost_per_day"],
        "rewards": activity["rewards"],
        "progress": 0.0,
        "start_time": Time.get_unix_time_from_system(),
        "last_payment": Time.get_unix_time_from_system()
    }

    active_activities[character.name] = activity_data
    activity_started.emit(activity["name"], character, ability)

    print("Started " + activity["name"] + " for " + character.name)
    return true

func _process_activities():
    """Process all active activities"""
    var current_time = Time.get_unix_time_from_system()

    for character_name in active_activities.keys():
        var activity = active_activities[character_name]
        var character = get_character_by_name(character_name)

        if not character:
            continue

        process_activity(character, activity, current_time)

func process_activity(character: Character, activity: Dictionary, current_time: float):
    """Process a single activity with offline progress tracking"""
    var days_elapsed = (current_time - activity.last_payment) / 86400.0

    # Process all elapsed time, not just daily chunks
    if days_elapsed > 0:
        # Calculate ability-based scaling
        var ability = activity.get("ability", "general")
        var ability_score = 10
        if ability != "general":
            ability_score = character.get(ability)
        var level_scaling = 1.0 + (ability_score - 10) * 0.1 # 10% bonus per point above 10

        # Handle costs for elapsed time
        var daily_cost = activity.get("cost_per_day", 0.0)
        var total_cost = daily_cost * days_elapsed
        if total_cost > 0:
            if character.gold >= total_cost:
                character.gold -= total_cost
            else:
                stop_activity(character.name, "Insufficient funds")
                return

        # Calculate progress with level scaling
        var base_daily_progress = activity.get("daily_progress", 0.0)
        var scaled_progress = base_daily_progress * level_scaling * days_elapsed
        activity["progress"] += scaled_progress

        # Apply rewards with level scaling
        apply_scaled_rewards(character, activity, days_elapsed, level_scaling)

        activity["last_payment"] = current_time
        activity_progress.emit(activity["name"], character, activity["progress"])

        # Check for completion (100% progress)
        if activity["progress"] >= 1.0:
            complete_activity(character, activity)

func apply_scaled_rewards(character: Character, activity: Dictionary, days_elapsed: float, level_scaling: float):
    """Apply scaled rewards from an activity based on time elapsed and ability level"""
    var rewards = activity.get("rewards", {})

    for reward_type in rewards.keys():
        var base_amount = rewards[reward_type]
        var scaled_amount = base_amount * days_elapsed * level_scaling

        match reward_type:
            "gold":
                character.gold += scaled_amount
            "strength_exp", "dexterity_exp", "constitution_exp", "intelligence_exp", "wisdom_exp", "charisma_exp":
                add_ability_experience(character, reward_type, scaled_amount)
            "language":
                learn_language(character, scaled_amount)
            _:
                # Other rewards would be handled by specific systems
                print(character.name + " gained " + str(scaled_amount) + " " + reward_type)

func apply_daily_rewards(character: Character, activity: Dictionary):
    """Apply daily rewards from an activity (legacy function)"""
    apply_scaled_rewards(character, activity, 1.0, 1.0)

func add_ability_experience(character: Character, ability_exp_type: String, amount: float):
    """Add experience to an ability score"""
    var ability = ability_exp_type.replace("_exp", "")
    var current_exp = character.get(ability + "_experience")
    if current_exp == null:
        current_exp = 0.0
    character.set(ability + "_experience", current_exp + amount)

    # Check for ability score increase (every 1000 exp = +1 ability score)
    var new_ability_score = int(current_exp + amount) / 1000
    var current_ability_score = character.get(ability)
    if current_ability_score == null:
        current_ability_score = 10

    if new_ability_score > current_ability_score - 10: # -10 because base is 10
        var increase = new_ability_score - (current_ability_score - 10)
        character.set(ability, current_ability_score + increase)
        print(character.name + " gained " + str(increase) + " " + ability + " (now " + str(character.get(ability)) + ")")

func learn_language(character: Character, progress: float):
    """Learn a language based on progress"""
    # This would be implemented with specific language learning activities
    # For now, just track progress
    var language_progress = character.get("language_learning_progress")
    if language_progress == null:
        language_progress = {}
    # Language learning would be handled by specific language activities

func complete_activity(character: Character, activity: Dictionary):
    """Complete an activity and apply final rewards"""
    var rewards = activity.get("rewards", {})

    # Apply completion rewards (usually higher than daily)
    for reward_type in rewards.keys():
        var amount = rewards[reward_type] * 10 # 10x daily reward for completion
        apply_daily_rewards(character, {reward_type: amount})

    activity_completed.emit(activity["name"], character, rewards)
    stop_activity(character.name, "Activity completed")

    print(character.name + " completed " + activity["name"])

func stop_activity(character_name: String, reason: String = ""):
    """Stop an activity for a character"""
    if character_name in active_activities:
        active_activities.erase(character_name)
        print("Stopped activity for " + character_name + " (" + reason + ")")

func get_character_by_name(name: String) -> Character:
    """Get character by name (placeholder - would use CharacterManager)"""
    # This would be implemented with proper character management
    return null

func get_active_activities() -> Dictionary:
    """Get all active activities"""
    return active_activities.duplicate()

func get_character_activity(character_name: String) -> Dictionary:
    """Get activity for specific character"""
    return active_activities.get(character_name, {})
