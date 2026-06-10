extends Node

# Magic Item Resource Manager
# Manages magic items using .tres Resource files for type safety

class_name MagicItemResourceManager

# Resource storage
var magic_items: Dictionary = {} # item_name -> MagicItemResource
var magic_items_by_rarity: Dictionary = {} # rarity -> Array[MagicItemResource]
var magic_items_by_type: Dictionary = {} # type -> Array[MagicItemResource]
var magic_items_by_category: Dictionary = {} # category -> Array[MagicItemResource]

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
		

	load_all_magic_items()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Load all magic items from .tres files
func load_all_magic_items() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Wait for data loader to finish loading
	await data_loader.data_loaded

	# Get magic items from data loader
	var all_magic_items = data_loader.get_all_magic_items()

	# Populate our storage
	for magic_item_resource in all_magic_items:
		magic_items[magic_item_resource.name] = magic_item_resource

	# Organize magic items by various criteria
	organize_magic_items()

	print("Loaded " + str(magic_items.size()) + " magic item resources")


# Organize magic items by various criteria
func organize_magic_items() -> void:
	# Clear existing organization
	magic_items_by_rarity.clear()
	magic_items_by_type.clear()
	magic_items_by_category.clear()

	# Organize magic items
	for magic_item_resource in magic_items.values():
		# By rarity
		var rarity = magic_item_resource.rarity.to_lower()
		if not magic_items_by_rarity.has(rarity):
			magic_items_by_rarity[rarity] = []
		magic_items_by_rarity[rarity].append(magic_item_resource)

		# By type
		var item_type = magic_item_resource.type.to_lower()
		if not magic_items_by_type.has(item_type):
			magic_items_by_type[item_type] = []
		magic_items_by_type[item_type].append(magic_item_resource)

		# By category
		var category = magic_item_resource.category.to_lower()
		if not magic_items_by_category.has(category):
			magic_items_by_category[category] = []
		magic_items_by_category[category].append(magic_item_resource)

# Public API

func get_magic_item(item_name: String) -> MagicItemResource:
	"""Get magic item resource by name"""
	return magic_items.get(item_name, null)

func get_all_magic_items() -> Array[MagicItemResource]:
	"""Get all magic item resources"""
	var all_items: Array[MagicItemResource] = []
	for magic_item_resource in magic_items.values():
		all_items.append(magic_item_resource)
	return all_items

func get_magic_items_by_rarity(rarity: String) -> Array[MagicItemResource]:
	"""Get all magic items of a specific rarity"""
	return magic_items_by_rarity.get(rarity.to_lower(), [])

func get_magic_items_by_type(item_type: String) -> Array[MagicItemResource]:
	"""Get all magic items of a specific type"""
	return magic_items_by_type.get(item_type.to_lower(), [])

func get_magic_items_by_category(category: String) -> Array[MagicItemResource]:
	"""Get all magic items of a specific category"""
	return magic_items_by_category.get(category.to_lower(), [])

func get_common_magic_items() -> Array[MagicItemResource]:
	"""Get all common magic items"""
	return get_magic_items_by_rarity("common")

func get_uncommon_magic_items() -> Array[MagicItemResource]:
	"""Get all uncommon magic items"""
	return get_magic_items_by_rarity("uncommon")

func get_rare_magic_items() -> Array[MagicItemResource]:
	"""Get all rare magic items"""
	return get_magic_items_by_rarity("rare")

func get_very_rare_magic_items() -> Array[MagicItemResource]:
	"""Get all very rare magic items"""
	return get_magic_items_by_rarity("very rare")

func get_legendary_magic_items() -> Array[MagicItemResource]:
	"""Get all legendary magic items"""
	return get_magic_items_by_rarity("legendary")

func get_artifact_magic_items() -> Array[MagicItemResource]:
	"""Get all artifact magic items"""
	return get_magic_items_by_rarity("artifact")

# Magic item filtering and search

func search_magic_items(query: String) -> Array[MagicItemResource]:
	"""Search magic items by name or description"""
	var results: Array[MagicItemResource] = []
	var query_lower = query.to_lower()

	for magic_item_resource in magic_items.values():
		if magic_item_resource.name.to_lower().contains(query_lower) or \
		   magic_item_resource.description.to_lower().contains(query_lower) or \
		   magic_item_resource.type.to_lower().contains(query_lower):
			results.append(magic_item_resource)

	return results

func get_magic_items_by_value_range(min_value: int, max_value: int) -> Array[MagicItemResource]:
	"""Filter magic items by value range"""
	var items_in_range: Array[MagicItemResource] = []

	for magic_item_resource in magic_items.values():
		var value = magic_item_resource.get_value_in_gold()
		if value >= min_value and value <= max_value:
			items_in_range.append(magic_item_resource)

	return items_in_range

func get_magic_items_for_character_level(level: int) -> Array[MagicItemResource]:
	"""Get appropriate magic items for a character level"""
	var appropriate_items: Array[MagicItemResource] = []

	# Determine appropriate rarity based on level
	var target_rarity = _get_rarity_for_level(level)
	var min_rarity_value = target_rarity - 1
	var max_rarity_value = target_rarity + 1

	for magic_item_resource in magic_items.values():
		var rarity_value = magic_item_resource.get_rarity_value()
		if rarity_value >= min_rarity_value and rarity_value <= max_rarity_value:
			appropriate_items.append(magic_item_resource)

	return appropriate_items

func _get_rarity_for_level(level: int) -> int:
	"""Get appropriate rarity value for character level"""
	if level <= 4:
		return 1  # Common
	elif level <= 8:
		return 2  # Uncommon
	elif level <= 12:
		return 3  # Rare
	elif level <= 16:
		return 4  # Very Rare
	else:
		return 5  # Legendary

func get_magic_items_with_attunement() -> Array[MagicItemResource]:
	"""Get all magic items that require attunement"""
	var attunement_items: Array[MagicItemResource] = []

	for magic_item_resource in magic_items.values():
		if magic_item_resource.requires_attunement():
			attunement_items.append(magic_item_resource)

	return attunement_items

func get_magic_items_without_attunement() -> Array[MagicItemResource]:
	"""Get all magic items that don't require attunement"""
	var non_attunement_items: Array[MagicItemResource] = []

	for magic_item_resource in magic_items.values():
		if not magic_item_resource.requires_attunement():
			non_attunement_items.append(magic_item_resource)

	return non_attunement_items

func get_magic_items_with_charges() -> Array[MagicItemResource]:
	"""Get all magic items with charges"""
	var charged_items: Array[MagicItemResource] = []

	for magic_item_resource in magic_items.values():
		if magic_item_resource.has_charges():
			charged_items.append(magic_item_resource)

	return charged_items

func get_magic_items_with_spells() -> Array[MagicItemResource]:
	"""Get all magic items that can cast spells"""
	var spell_items: Array[MagicItemResource] = []

	for magic_item_resource in magic_items.values():
		if magic_item_resource.can_cast_spell():
			spell_items.append(magic_item_resource)

	return spell_items

func get_cursed_magic_items() -> Array[MagicItemResource]:
	"""Get all cursed magic items"""
	var cursed_items: Array[MagicItemResource] = []

	for magic_item_resource in magic_items.values():
		if magic_item_resource.is_cursed():
			cursed_items.append(magic_item_resource)

	return cursed_items

func get_sentient_magic_items() -> Array[MagicItemResource]:
	"""Get all sentient magic items"""
	var sentient_items: Array[MagicItemResource] = []

	for magic_item_resource in magic_items.values():
		if magic_item_resource.is_sentient():
			sentient_items.append(magic_item_resource)

	return sentient_items

# Magic item recommendations

func get_magic_item_recommendations_for_character(character: Character) -> Dictionary:
	"""Get magic item recommendations for a character"""
	var recommendations = {
		"weapons": [],
		"armor": [],
		"accessories": [],
		"utility": []
	}

	# Get appropriate items for character level
	var appropriate_items = get_magic_items_for_character_level(character.level)

	# Categorize recommendations
	for magic_item_resource in appropriate_items:
		var item_type = magic_item_resource.type.to_lower()

		if "sword" in item_type or "weapon" in item_type:
			recommendations.weapons.append(magic_item_resource)
		elif "armor" in item_type or "shield" in item_type:
			recommendations.armor.append(magic_item_resource)
		elif "ring" in item_type or "amulet" in item_type or "cloak" in item_type:
			recommendations.accessories.append(magic_item_resource)
		else:
			recommendations.utility.append(magic_item_resource)

	# Sort by value/usefulness
	recommendations.weapons.sort_custom(func(a, b): return a.get_value_in_gold() > b.get_value_in_gold())
	recommendations.armor.sort_custom(func(a, b): return a.get_value_in_gold() > b.get_value_in_gold())
	recommendations.accessories.sort_custom(func(a, b): return a.get_value_in_gold() > b.get_value_in_gold())
	recommendations.utility.sort_custom(func(a, b): return a.get_value_in_gold() > b.get_value_in_gold())

	return recommendations

func get_magic_items_for_encounter_reward(party_level: int, encounter_difficulty: String = "medium") -> Array[MagicItemResource]:
	"""Get appropriate magic items for encounter rewards"""
	var reward_items: Array[MagicItemResource] = []

	# Determine reward rarity based on encounter difficulty and party level
	var base_rarity = _get_rarity_for_level(party_level)
	var difficulty_modifier = _get_difficulty_modifier(encounter_difficulty)
	var target_rarity = base_rarity + difficulty_modifier

	# Get items of appropriate rarity
	var rarity_names = ["common", "uncommon", "rare", "very rare", "legendary", "artifact"]
	if target_rarity <= rarity_names.size():
		var target_rarity_name = rarity_names[target_rarity - 1]
		reward_items = get_magic_items_by_rarity(target_rarity_name)

	# If no items of target rarity, get items of nearby rarities
	if reward_items.is_empty():
		for i in range(max(1, target_rarity - 1), min(rarity_names.size() + 1, target_rarity + 2)):
			if i <= rarity_names.size():
				reward_items.append_array(get_magic_items_by_rarity(rarity_names[i - 1]))

	return reward_items

func _get_difficulty_modifier(difficulty: String) -> int:
	"""Get rarity modifier based on encounter difficulty"""
	match difficulty.to_lower():
		"easy": return -1
		"medium": return 0
		"hard": return 1
		"deadly": return 2
		_: return 0

# Magic item analysis and statistics

func get_magic_item_statistics() -> Dictionary:
	"""Get statistics about loaded magic items"""
	var stats = {
		"total_items": magic_items.size(),
		"by_rarity": {},
		"by_type": {},
		"by_category": {},
		"with_attunement": 0,
		"without_attunement": 0,
		"with_charges": 0,
		"with_spells": 0,
		"cursed": 0,
		"sentient": 0,
		"total_value_range": {"min": 0, "max": 0}
	}

	# Count by rarity
	for rarity in magic_items_by_rarity.keys():
		stats.by_rarity[rarity] = magic_items_by_rarity[rarity].size()

	# Count by type
	for item_type in magic_items_by_type.keys():
		stats.by_type[item_type] = magic_items_by_type[item_type].size()

	# Count by category
	for category in magic_items_by_category.keys():
		stats.by_category[category] = magic_items_by_category[category].size()

	# Count special features
	var min_value = 999999
	var max_value = 0

	for magic_item_resource in magic_items.values():
		if magic_item_resource.requires_attunement():
			stats.with_attunement += 1
		else:
			stats.without_attunement += 1

		if magic_item_resource.has_charges():
			stats.with_charges += 1

		if magic_item_resource.can_cast_spell():
			stats.with_spells += 1

		if magic_item_resource.is_cursed():
			stats.cursed += 1

		if magic_item_resource.is_sentient():
			stats.sentient += 1

		var value = magic_item_resource.get_value_in_gold()
		min_value = min(min_value, value)
		max_value = max(max_value, value)

	stats.total_value_range.min = min_value
	stats.total_value_range.max = max_value

	return stats

func print_magic_item_summary() -> void:
	"""Print summary of loaded magic items"""
	var stats = get_magic_item_statistics()
	print("=== Magic Item Summary ===")
	print("Total items: " + str(stats.total_items))
	print("By rarity: " + str(stats.by_rarity))
	print("By type: " + str(stats.by_type))
	print("By category: " + str(stats.by_category))
	print("With attunement: " + str(stats.with_attunement))
	print("Without attunement: " + str(stats.without_attunement))
	print("With charges: " + str(stats.with_charges))
	print("With spells: " + str(stats.with_spells))
	print("Cursed: " + str(stats.cursed))
	print("Sentient: " + str(stats.sentient))
	print("Value range: " + str(stats.total_value_range.min) + " - " + str(stats.total_value_range.max) + " gp")

# Helper functions

func _magic_item_resource_to_dict(magic_item_resource: MagicItemResource) -> Dictionary:
	"""Convert MagicItemResource to legacy Dictionary format"""
	return {
		"name": magic_item_resource.name,
		"type": magic_item_resource.type,
		"rarity": magic_item_resource.rarity,
		"attunement": magic_item_resource.attunement,
		"description": magic_item_resource.description,
		"properties": magic_item_resource.properties,
		"effects": magic_item_resource.effects,
		"requirements": magic_item_resource.requirements,
		"weight": magic_item_resource.weight,
		"value": magic_item_resource.value,
		"category": magic_item_resource.category,
		"charges": magic_item_resource.charges,
		"max_charges": magic_item_resource.max_charges,
		"recharge_rate": magic_item_resource.recharge_rate,
		"spell_list": magic_item_resource.spell_list,
		"spell_level": magic_item_resource.spell_level,
		"uses_per_day": magic_item_resource.uses_per_day,
		"cursed": magic_item_resource.cursed,
		"sentient": magic_item_resource.sentient,
		"armor_class_bonus": magic_item_resource.armor_class_bonus,
		"attack_bonus": magic_item_resource.attack_bonus,
		"damage_bonus": magic_item_resource.damage_bonus,
		"ability_bonuses": magic_item_resource.ability_bonuses,
		"skill_bonuses": magic_item_resource.skill_bonuses,
		"saving_throw_bonuses": magic_item_resource.saving_throw_bonuses,
		"resistance_types": magic_item_resource.resistance_types,
		"immunity_types": magic_item_resource.immunity_types,
		"vulnerability_types": magic_item_resource.vulnerability_types
	}
