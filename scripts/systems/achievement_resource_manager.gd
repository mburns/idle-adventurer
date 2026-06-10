extends Node

# Achievement Resource Manager
# Manages achievements using the hybrid YAML + Resource approach

class_name AchievementResourceManager

# Resource storage
var achievements: Dictionary = {} # achievement_id -> AchievementResource
var achievements_by_category: Dictionary = {} # category -> Array[AchievementResource]
var achievements_by_rarity: Dictionary = {} # rarity -> Array[AchievementResource]

# Resource data loader
var data_loader: ResourceDataLoader

func _ready() -> void:
	# Use global data loader if available
	if Engine.has_singleton("AutoloadManager"):
		var autoload_manager = Engine.get_singleton("AutoloadManager")
		if autoload_manager and autoload_manager.data_loader:
			data_loader = autoload_manager.data_loader
		else:
			data_loader = ResourceDataLoader.new()
			
	else:
		data_loader = ResourceDataLoader.new()
		

	load_all_achievements()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Load all achievements from .tres files
func load_all_achievements() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Wait for data loader to finish loading
	await data_loader.data_loaded

	# Get achievements from data loader
	var all_achievements = data_loader.get_all_achievements()

	# Populate our storage
	for achievement_id in all_achievements.keys():
		var achievement_data = all_achievements[achievement_id]
		achievements[achievement_id] = achievement_data

	# Organize achievements by various criteria
	organize_achievements()

	print("Loaded " + str(achievements.size()) + " achievement resources")

# Organize achievements by various criteria
func organize_achievements() -> void:
	achievements_by_category.clear()
	achievements_by_rarity.clear()

	for achievement_id in achievements:
		var achievement = achievements[achievement_id]

		# Organize by category
		if not achievements_by_category.has(achievement.category):
			achievements_by_category[achievement.category] = []
		achievements_by_category[achievement.category].append(achievement)

		# Organize by rarity
		if not achievements_by_rarity.has(achievement.rarity):
			achievements_by_rarity[achievement.rarity] = []
		achievements_by_rarity[achievement.rarity].append(achievement)

# Public API methods
func get_achievement_by_id(achievement_id: String) -> AchievementResource:
	"""Get a specific achievement by ID"""
	return achievements.get(achievement_id, null)

func get_achievements_by_category(category: String) -> Array[AchievementResource]:
	"""Get all achievements in a specific category"""
	return achievements_by_category.get(category, [])

func get_achievements_by_rarity(rarity: String) -> Array[AchievementResource]:
	"""Get all achievements of a specific rarity"""
	return achievements_by_rarity.get(rarity, [])

func get_all_achievements() -> Dictionary:
	"""Get all achievements"""
	return achievements.duplicate()

func get_unlocked_achievements() -> Array[AchievementResource]:
	"""Get all unlocked achievements"""
	var unlocked = []
	for achievement_id in achievements:
		var achievement = achievements[achievement_id]
		if achievement.is_unlocked():
			unlocked.append(achievement)
	return unlocked

func get_available_achievements_for_character(character: Character) -> Array[AchievementResource]:
	"""Get achievements that a character can potentially unlock"""
	var available = []
	for achievement_id in achievements:
		var achievement = achievements[achievement_id]
		if not achievement.is_unlocked() and can_unlock_achievement(character, achievement):
			available.append(achievement)
	return available

func can_unlock_achievement(_character: Character, _achievement: AchievementResource) -> bool:
	"""Check if a character can unlock a specific achievement"""
	# TODO This would contain the logic to check achievement requirements
	# For now, return true for all achievements
	return true

func unlock_achievement(character: Character, achievement_id: String) -> bool:
	"""Unlock an achievement for a character"""
	var achievement = get_achievement_by_id(achievement_id)
	if achievement == null or achievement.is_unlocked():
		return false

	achievement.unlocked = true
	achievement.unlocked_at = Time.get_unix_time_from_system()

	# Apply rewards to character
	apply_achievement_rewards(character, achievement)

	return true

func apply_achievement_rewards(character: Character, achievement: AchievementResource):
	"""Apply achievement rewards to a character"""
	var rewards = achievement.rewards

	if rewards.has("xp"):
		character.add_experience(rewards.xp)

	if rewards.has("gold"):
		character.add_gold(rewards.gold)

	# Add other reward types as needed
