extends Resource

# D&D Achievement as a Godot Resource for better editor integration

class_name AchievementResource

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var category: String = ""
@export var rarity: String = ""
@export var requirements: Dictionary = {}
@export var rewards: Dictionary = {}
@export var unlocked: bool = false
@export var progress: float = 0.0
@export var unlocked_at: int = 0

func is_unlocked() -> bool:
	return unlocked

func get_progress_percentage() -> float:
	return progress * 100.0

func get_rarity_color() -> Color:
	match rarity:
		"COMMON": return Color.GREEN
		"UNCOMMON": return Color.BLUE
		"RARE": return Color.PURPLE
		"EPIC": return Color.ORANGE
		"LEGENDARY": return Color.GOLD
		_: return Color.WHITE

func get_category_name() -> String:
	match category:
		"CHARACTER_LEVEL": return "Character Level"
		"SKILL_MASTERY": return "Skill Mastery"
		"EXPLORATION": return "Exploration"
		"SOCIAL": return "Social"
		"COMBAT": return "Combat"
		_: return category
