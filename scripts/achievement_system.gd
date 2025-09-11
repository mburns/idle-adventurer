extends Node

# Achievement system for tracking milestones and rewards

class_name AchievementSystem

signal achievement_unlocked(achievement: Achievement)
signal achievement_progress(achievement: Achievement, progress: float)
signal reward_granted(character: Character, reward: Dictionary)

# Achievement categories
enum AchievementCategory {
    CHARACTER_LEVEL,
    SKILL_MASTERY,
    GOLD_EARNED,
    ITEMS_CRAFTED,
    QUESTS_COMPLETED,
    FACTION_REPUTATION,
    TIME_PLAYED,
    COMBAT_VICTORIES,
    EXPLORATION,
    SOCIAL
}

# Achievement rarity levels
enum AchievementRarity {
    COMMON,
    UNCOMMON,
    RARE,
    EPIC,
    LEGENDARY
}

# Achievement data structure
class Achievement:
    var id: String
    var name: String
    var description: String
    var category: AchievementCategory
    var rarity: AchievementRarity
    var requirements: Dictionary
    var rewards: Dictionary
    var unlocked: bool = false
    var progress: float = 0.0
    var unlocked_at: int = 0

    func _init(achievement_id: String, achievement_name: String, achievement_description: String,
               achievement_category: AchievementCategory, achievement_rarity: AchievementRarity,
               achievement_requirements: Dictionary, achievement_rewards: Dictionary):
        id = achievement_id
        name = achievement_name
        description = achievement_description
        category = achievement_category
        rarity = achievement_rarity
        requirements = achievement_requirements
        rewards = achievement_rewards

var achievements: Dictionary = {}
var character_achievements: Dictionary = {} # character_name -> achievement_data
var achievement_templates: Dictionary = {}

func _init() -> void:
    setup_achievement_system()

func setup_achievement_system() -> void:
    """Initialize the achievement system with predefined achievements"""
    create_achievement_templates()
    load_character_achievements()

func create_achievement_templates() -> void:
    """Create template achievements for different categories"""

    # Character Level Achievements
    create_achievement_template("level_5", "Rising Star", "Reach level 5",
                               AchievementCategory.CHARACTER_LEVEL, AchievementRarity.COMMON,
                               {"level": 5}, {"xp": 100, "gold": 50})

    create_achievement_template("level_10", "Experienced Adventurer", "Reach level 10",
                               AchievementCategory.CHARACTER_LEVEL, AchievementRarity.UNCOMMON,
                               {"level": 10}, {"xp": 500, "gold": 200})

    create_achievement_template("level_20", "Master Adventurer", "Reach level 20",
                               AchievementCategory.CHARACTER_LEVEL, AchievementRarity.LEGENDARY,
                               {"level": 20}, {"xp": 2000, "gold": 1000, "title": "Master"})

    # Skill Mastery Achievements
    create_achievement_template("skill_master_1", "Skillful", "Master your first skill",
                               AchievementCategory.SKILL_MASTERY, AchievementRarity.COMMON,
                               {"skills_mastered": 1}, {"xp": 50, "gold": 25})

    create_achievement_template("skill_master_5", "Multi-talented", "Master 5 different skills",
                               AchievementCategory.SKILL_MASTERY, AchievementRarity.UNCOMMON,
                               {"skills_mastered": 5}, {"xp": 300, "gold": 150})

    create_achievement_template("skill_master_all", "Jack of All Trades", "Master all available skills",
                               AchievementCategory.SKILL_MASTERY, AchievementRarity.LEGENDARY,
                               {"skills_mastered": 20}, {"xp": 1000, "gold": 500, "title": "Master of All"})

    # Gold Achievements
    create_achievement_template("gold_100", "Wealthy", "Accumulate 100 gold pieces",
                               AchievementCategory.GOLD_EARNED, AchievementRarity.COMMON,
                               {"gold": 100}, {"gold": 50})

    create_achievement_template("gold_1000", "Rich", "Accumulate 1,000 gold pieces",
                               AchievementCategory.GOLD_EARNED, AchievementRarity.UNCOMMON,
                               {"gold": 1000}, {"gold": 200})

    create_achievement_template("gold_10000", "Millionaire", "Accumulate 10,000 gold pieces",
                               AchievementCategory.GOLD_EARNED, AchievementRarity.EPIC,
                               {"gold": 10000}, {"gold": 1000, "title": "The Wealthy"})

    # Crafting Achievements
    create_achievement_template("craft_10", "Apprentice Crafter", "Craft 10 items",
                               AchievementCategory.ITEMS_CRAFTED, AchievementRarity.COMMON,
                               {"items_crafted": 10}, {"xp": 100, "gold": 50})

    create_achievement_template("craft_100", "Master Crafter", "Craft 100 items",
                               AchievementCategory.ITEMS_CRAFTED, AchievementRarity.UNCOMMON,
                               {"items_crafted": 100}, {"xp": 500, "gold": 200})

    create_achievement_template("craft_legendary", "Legendary Artisan", "Craft a legendary item",
                               AchievementCategory.ITEMS_CRAFTED, AchievementRarity.LEGENDARY,
                               {"legendary_items_crafted": 1}, {"xp": 1000, "gold": 500, "title": "Legendary Artisan"})

    # Faction Achievements
    create_achievement_template("faction_friendly", "Well Connected", "Reach friendly reputation with any faction",
                               AchievementCategory.FACTION_REPUTATION, AchievementRarity.COMMON,
                               {"faction_reputation": 20}, {"xp": 100, "gold": 50})

    create_achievement_template("faction_exalted", "Faction Champion", "Reach exalted reputation with any faction",
                               AchievementCategory.FACTION_REPUTATION, AchievementRarity.EPIC,
                               {"faction_reputation": 100}, {"xp": 500, "gold": 200, "title": "Champion"})

    create_achievement_template("faction_all_friendly", "Diplomat", "Reach friendly reputation with all factions",
                               AchievementCategory.FACTION_REPUTATION, AchievementRarity.LEGENDARY,
                               {"all_factions_friendly": true}, {"xp": 1000, "gold": 500, "title": "Master Diplomat"})

    # Time Played Achievements
    create_achievement_template("time_1_hour", "Dedicated", "Play for 1 hour",
                               AchievementCategory.TIME_PLAYED, AchievementRarity.COMMON,
                               {"time_played": 3600}, {"xp": 50, "gold": 25})

    create_achievement_template("time_24_hours", "Devoted", "Play for 24 hours",
                               AchievementCategory.TIME_PLAYED, AchievementRarity.UNCOMMON,
                               {"time_played": 86400}, {"xp": 200, "gold": 100})

    create_achievement_template("time_168_hours", "Addicted", "Play for 168 hours (1 week)",
                               AchievementCategory.TIME_PLAYED, AchievementRarity.EPIC,
                               {"time_played": 604800}, {"xp": 500, "gold": 250, "title": "The Dedicated"})

func create_achievement_template(id: String, name: String, description: String,
                                category: AchievementCategory, rarity: AchievementRarity,
                                requirements: Dictionary, rewards: Dictionary) -> void:
    """Create an achievement template"""
    var achievement = Achievement.new(id, name, description, category, rarity, requirements, rewards)
    achievement_templates[id] = achievement

func initialize_character_achievements(character: Character) -> void:
    """Initialize achievements for a new character"""
    var character_data = {
        "achievements": {},
        "progress": {},
        "unlocked_count": 0,
        "total_xp_earned": 0,
        "total_gold_earned": 0
    }

    # Create instances of all achievements for this character
    for achievement_id in achievement_templates.keys():
        var template = achievement_templates[achievement_id]
        var achievement = Achievement.new(template.id, template.name, template.description,
                                        template.category, template.rarity, template.requirements, template.rewards)
        character_data.achievements[achievement_id] = achievement
        character_data.progress[achievement_id] = 0.0

    character_achievements[character.name] = character_data
    print("Initialized achievements for " + character.name)

func check_achievements(character: Character, event_type: String, event_data: Dictionary) -> void:
    """Check and update achievements based on character events"""
    if not character.name in character_achievements:
        initialize_character_achievements(character)

    var character_data = character_achievements[character.name]
    var achievements_updated = false

    for achievement_id in character_data.achievements.keys():
        var achievement = character_data.achievements[achievement_id]

        if not achievement.unlocked:
            var progress = calculate_achievement_progress(achievement, character, event_type, event_data)

            if progress != character_data.progress[achievement_id]:
                character_data.progress[achievement_id] = progress
                achievement.progress = progress
                achievement_progress.emit(achievement, progress)
                achievements_updated = true

                if progress >= 1.0:
                    unlock_achievement(character, achievement)
                    achievements_updated = true

    if achievements_updated:
        save_character_achievements(character.name)

func calculate_achievement_progress(achievement: Achievement, character: Character, event_type: String, event_data: Dictionary) -> float:
    """Calculate progress towards an achievement"""
    var progress = 0.0

    match achievement.category:
        AchievementCategory.CHARACTER_LEVEL:
            if "level" in achievement.requirements:
                progress = min(float(character.level) / float(achievement.requirements.level), 1.0)

        AchievementCategory.SKILL_MASTERY:
            if "skills_mastered" in achievement.requirements:
                var mastered_skills = get_mastered_skills_count(character)
                progress = min(float(mastered_skills) / float(achievement.requirements.skills_mastered), 1.0)

        AchievementCategory.GOLD_EARNED:
            if "gold" in achievement.requirements:
                progress = min(character.gold / float(achievement.requirements.gold), 1.0)

        AchievementCategory.ITEMS_CRAFTED:
            if "items_crafted" in achievement.requirements:
                var items_crafted = get_items_crafted_count(character)
                progress = min(float(items_crafted) / float(achievement.requirements.items_crafted), 1.0)

        AchievementCategory.FACTION_REPUTATION:
            if "faction_reputation" in achievement.requirements:
                var max_reputation = get_max_faction_reputation(character)
                progress = min(max_reputation / float(achievement.requirements.faction_reputation), 1.0)

        AchievementCategory.TIME_PLAYED:
            if "time_played" in achievement.requirements:
                var time_played = get_character_play_time(character)
                progress = min(time_played / float(achievement.requirements.time_played), 1.0)

    return progress

func unlock_achievement(character: Character, achievement: Achievement) -> void:
    """Unlock an achievement and grant rewards"""
    achievement.unlocked = true
    achievement.unlocked_at = Time.get_unix_time_from_system()

    var character_data = character_achievements[character.name]
    character_data.unlocked_count += 1

    # Grant rewards
    grant_achievement_rewards(character, achievement)

    # Emit signals
    achievement_unlocked.emit(achievement)

    print("Achievement unlocked: " + achievement.name + " for " + character.name)

func grant_achievement_rewards(character: Character, achievement: Achievement) -> void:
    """Grant rewards for unlocking an achievement"""
    var rewards = achievement.rewards

    if "xp" in rewards:
        character.add_experience(rewards.xp)
        print("  +" + str(rewards.xp) + " XP")

    if "gold" in rewards:
        character.gold += rewards.gold
        print("  +" + str(rewards.gold) + " gold")

    if "title" in rewards:
        # Add title to character (this would be implemented with character system)
        print("  +Title: " + rewards.title)

    # Emit reward signal
    reward_granted.emit(character, rewards)

func get_mastered_skills_count(character: Character) -> int:
    """Get count of mastered skills for character"""
    # This would be implemented with skill system
    return 0

func get_items_crafted_count(character: Character) -> int:
    """Get count of items crafted by character"""
    # This would be implemented with crafting system
    return 0

func get_max_faction_reputation(character: Character) -> int:
    """Get maximum faction reputation for character"""
    # This would be implemented with faction system
    return 0

func get_character_play_time(character: Character) -> int:
    """Get total play time for character in seconds"""
    # This would be implemented with time tracking
    return 0

func get_character_achievements(character: Character) -> Dictionary:
    """Get all achievements for a character"""
    if not character.name in character_achievements:
        initialize_character_achievements(character)

    return character_achievements[character.name].achievements

func get_unlocked_achievements(character: Character) -> Array:
    """Get unlocked achievements for a character"""
    var achievements = get_character_achievements(character)
    var unlocked = []

    for achievement in achievements.values():
        if achievement.unlocked:
            unlocked.append(achievement)

    return unlocked

func get_achievement_progress(character: Character, achievement_id: String) -> float:
    """Get progress for a specific achievement"""
    if not character.name in character_achievements:
        return 0.0

    return character_achievements[character.name].progress.get(achievement_id, 0.0)

func save_character_achievements(character_name: String):
    """Save character achievements to file"""
    var file_path = "user://achievements/" + character_name + ".dat"
    var dir = DirAccess.open("user://")

    if not dir.dir_exists("achievements"):
        dir.make_dir("achievements")

    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(character_achievements[character_name]))
        file.close()

func load_character_achievements():
    """Load all character achievements from files"""
    var dir = DirAccess.open("user://")

    if not dir.dir_exists("achievements"):
        return

    var achievements_dir = DirAccess.open("user://achievements/")
    if achievements_dir:
        for file_name in achievements_dir.get_files():
            if file_name.ends_with(".dat"):
                var character_name = file_name.get_basename()
                var file_path = "user://achievements/" + file_name
                var file = FileAccess.open(file_path, FileAccess.READ)

                if file:
                    var json_string = file.get_as_text()
                    file.close()

                    var json = JSON.new()
                    var parse_result = json.parse(json_string)
                    if parse_result == OK:
                        character_achievements[character_name] = json.get_data()

func get_achievement_statistics(character: Character) -> Dictionary:
    """Get achievement statistics for a character"""
    if not character.name in character_achievements:
        return {}

    var character_data = character_achievements[character.name]
    var total_achievements = achievement_templates.size()
    var unlocked_achievements = character_data.unlocked_count

    return {
        "total_achievements": total_achievements,
        "unlocked_achievements": unlocked_achievements,
        "completion_percentage": (float(unlocked_achievements) / float(total_achievements)) * 100.0,
        "total_xp_earned": character_data.total_xp_earned,
        "total_gold_earned": character_data.total_gold_earned
    }
