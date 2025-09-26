extends Node
class_name AchievementSystem

# Achievement system for tracking milestones and rewards

# Achievement data structure
class Achievement extends RefCounted:
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
        unlocked = false
        progress = 0.0
        unlocked_at = 0

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

signal achievement_unlocked(achievement: Achievement)
signal achievement_progress(achievement: Achievement, progress: float)
signal reward_granted(character: Character, reward: Dictionary)


var achievements: Dictionary = {}
var character_achievements: Dictionary = {} # character_name -> achievement_data
var achievement_templates: Dictionary = {}

func _init() -> void:
    setup_achievement_system()

func setup_achievement_system() -> void:
    """Initialize the achievement system with predefined achievements"""
    load_achievement_templates()
    load_character_achievements()

func load_achievement_templates() -> void:
    """Load achievement templates using the resource manager"""
    var achievement_manager = AutoloadManager.get_achievement_resource_manager()
    if achievement_manager == null:
        print("Error: Achievement manager not available")
        return

    # Copy achievements from resource manager to local storage
    var all_achievements = achievement_manager.get_all_achievements()
    for achievement_id in all_achievements:
        var achievement_resource = all_achievements[achievement_id]

        # Convert resource to legacy Achievement class
        var category = string_to_achievement_category(achievement_resource.category)
        var rarity = string_to_achievement_rarity(achievement_resource.rarity)

        create_achievement_template(
            achievement_resource.id,
            achievement_resource.name,
            achievement_resource.description,
            category,
            rarity,
            achievement_resource.requirements,
            achievement_resource.rewards
        )

    print("Loaded " + str(achievement_templates.size()) + " achievement templates")

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

# YAML parsing functions for achievements
# Custom YAML parsing functions removed - now using unified YAMLParser via resource manager

# Enum conversion functions
func string_to_achievement_category(category_str: String) -> AchievementCategory:
    """Convert string to AchievementCategory enum"""
    match category_str:
        "CHARACTER_LEVEL":
            return AchievementCategory.CHARACTER_LEVEL
        "SKILL_MASTERY":
            return AchievementCategory.SKILL_MASTERY
        "GOLD_EARNED":
            return AchievementCategory.GOLD_EARNED
        "ITEMS_CRAFTED":
            return AchievementCategory.ITEMS_CRAFTED
        "QUESTS_COMPLETED":
            return AchievementCategory.QUESTS_COMPLETED
        "FACTION_REPUTATION":
            return AchievementCategory.FACTION_REPUTATION
        "TIME_PLAYED":
            return AchievementCategory.TIME_PLAYED
        "COMBAT_VICTORIES":
            return AchievementCategory.COMBAT_VICTORIES
        "EXPLORATION":
            return AchievementCategory.EXPLORATION
        "SOCIAL":
            return AchievementCategory.SOCIAL
        _:
            print("Warning: Unknown achievement category: " + category_str)
            return AchievementCategory.CHARACTER_LEVEL

func string_to_achievement_rarity(rarity_str: String) -> AchievementRarity:
    """Convert string to AchievementRarity enum"""
    match rarity_str:
        "COMMON":
            return AchievementRarity.COMMON
        "UNCOMMON":
            return AchievementRarity.UNCOMMON
        "RARE":
            return AchievementRarity.RARE
        "EPIC":
            return AchievementRarity.EPIC
        "LEGENDARY":
            return AchievementRarity.LEGENDARY
        _:
            print("Warning: Unknown achievement rarity: " + rarity_str)
            return AchievementRarity.COMMON
