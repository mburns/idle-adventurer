extends Node

# Monster Resource Manager
# Manages monsters using .tres Resource files for type safety

class_name MonsterResourceManager

# Resource storage
var monsters: Dictionary = {} # monster_name -> MonsterResource
var monsters_by_cr: Dictionary = {} # challenge_rating -> Array[MonsterResource]
var monsters_by_type: Dictionary = {} # type -> Array[MonsterResource]
var monsters_by_size: Dictionary = {} # size -> Array[MonsterResource]

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
		

	load_all_monsters()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Load all monsters from .tres files
func load_all_monsters() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Wait for data loader to finish loading
	await data_loader.data_loaded

	# Get monsters from data loader
	var all_monsters = data_loader.get_all_monsters()

	# Populate our storage
	for monster_resource in all_monsters:
		monsters[monster_resource.name] = monster_resource

	# Organize monsters by various criteria
	organize_monsters()

	print("Loaded " + str(monsters.size()) + " monster resources")


# Organize monsters by various criteria
func organize_monsters() -> void:
	# Clear existing organization
	monsters_by_cr.clear()
	monsters_by_type.clear()
	monsters_by_size.clear()

	# Organize monsters
	for monster_resource in monsters.values():
		# By challenge rating
		var cr = monster_resource.challenge_rating
		if not monsters_by_cr.has(cr):
			monsters_by_cr[cr] = []
		monsters_by_cr[cr].append(monster_resource)

		# By type
		var creature_type = monster_resource.get_creature_type()
		if not monsters_by_type.has(creature_type):
			monsters_by_type[creature_type] = []
		monsters_by_type[creature_type].append(monster_resource)

		# By size
		var size = monster_resource.get_size_category()
		if not monsters_by_size.has(size):
			monsters_by_size[size] = []
		monsters_by_size[size].append(monster_resource)

# Public API

func get_monster(monster_name: String) -> MonsterResource:
	"""Get monster resource by name"""
	return monsters.get(monster_name, null)

func get_all_monsters() -> Array[MonsterResource]:
	"""Get all monster resources"""
	var all_monsters: Array[MonsterResource] = []
	for monster_resource in monsters.values():
		all_monsters.append(monster_resource)
	return all_monsters

func get_monsters_by_cr(challenge_rating: String) -> Array[MonsterResource]:
	"""Get all monsters of a specific challenge rating"""
	return monsters_by_cr.get(challenge_rating, [])

func get_monsters_by_type(creature_type: String) -> Array[MonsterResource]:
	"""Get all monsters of a specific type"""
	return monsters_by_type.get(creature_type.to_lower(), [])

func get_monsters_by_size(size: String) -> Array[MonsterResource]:
	"""Get all monsters of a specific size"""
	return monsters_by_size.get(size.to_lower(), [])

func get_monsters_by_cr_range(min_cr: float, max_cr: float) -> Array[MonsterResource]:
	"""Get monsters within a challenge rating range"""
	var monsters_in_range: Array[MonsterResource] = []

	for monster_resource in monsters.values():
		var cr_value = monster_resource.get_challenge_rating_value()
		if cr_value >= min_cr and cr_value <= max_cr:
			monsters_in_range.append(monster_resource)

	return monsters_in_range

func get_monsters_for_party_level(party_level: int, party_size: int = 4) -> Array[MonsterResource]:
	"""Get appropriate monsters for a party of given level and size"""
	var appropriate_monsters: Array[MonsterResource] = []

	# Calculate appropriate CR range based on party level and size
	var target_cr = party_level / float(party_size)
	var min_cr = max(0.125, target_cr * 0.5)
	var max_cr = min(30.0, target_cr * 2.0)

	return get_monsters_by_cr_range(min_cr, max_cr)

# Monster filtering and search

func search_monsters(query: String) -> Array[MonsterResource]:
	"""Search monsters by name or description"""
	var results: Array[MonsterResource] = []
	var query_lower = query.to_lower()

	for monster_resource in monsters.values():
		if monster_resource.name.to_lower().contains(query_lower) or \
		   monster_resource.type.to_lower().contains(query_lower) or \
		   monster_resource.alignment.to_lower().contains(query_lower):
			results.append(monster_resource)

	return results

func get_monsters_with_trait(trait_name: String) -> Array[MonsterResource]:
	"""Get monsters that have a specific trait"""
	var monsters_with_trait: Array[MonsterResource] = []

	for monster_resource in monsters.values():
		if monster_resource.has_trait(trait_name):
			monsters_with_trait.append(monster_resource)

	return monsters_with_trait

func get_monsters_with_resistance(damage_type: String) -> Array[MonsterResource]:
	"""Get monsters with resistance to a specific damage type"""
	var resistant_monsters: Array[MonsterResource] = []

	for monster_resource in monsters.values():
		if monster_resource.has_resistance(damage_type):
			resistant_monsters.append(monster_resource)

	return resistant_monsters

func get_monsters_with_immunity(damage_type: String) -> Array[MonsterResource]:
	"""Get monsters with immunity to a specific damage type"""
	var immune_monsters: Array[MonsterResource] = []

	for monster_resource in monsters.values():
		if monster_resource.has_immunity(damage_type):
			immune_monsters.append(monster_resource)

	return immune_monsters

func get_legendary_monsters() -> Array[MonsterResource]:
	"""Get all legendary monsters"""
	var legendary_monsters: Array[MonsterResource] = []

	for monster_resource in monsters.values():
		if monster_resource.is_legendary():
			legendary_monsters.append(monster_resource)

	return legendary_monsters

func get_monsters_with_darkvision() -> Array[MonsterResource]:
	"""Get all monsters with darkvision"""
	var darkvision_monsters: Array[MonsterResource] = []

	for monster_resource in monsters.values():
		if monster_resource.has_darkvision():
			darkvision_monsters.append(monster_resource)

	return darkvision_monsters

# Encounter building

func build_encounter(party_level: int, party_size: int = 4, encounter_difficulty: String = "medium") -> Array[MonsterResource]:
	"""Build an encounter for a party"""
	var encounter: Array[MonsterResource] = []
	var target_xp = calculate_target_xp(party_level, party_size, encounter_difficulty)
	var current_xp = 0

	# Get appropriate monsters
	var available_monsters = get_monsters_for_party_level(party_level, party_size)

	# Sort by XP value
	available_monsters.sort_custom(func(a, b): return a.get_experience_points() < b.get_experience_points())

	# Build encounter
	while current_xp < target_xp and available_monsters.size() > 0:
		var monster = available_monsters[randi() % available_monsters.size()]
		var monster_xp = monster.get_experience_points()

		# Check if adding this monster would exceed target
		if current_xp + monster_xp <= target_xp * 1.2:  # Allow 20% over target
			encounter.append(monster)
			current_xp += monster_xp
		else:
			break

	return encounter

func calculate_target_xp(party_level: int, party_size: int, difficulty: String) -> int:
	"""Calculate target XP for an encounter"""
	var base_xp_per_player = get_xp_per_player_by_level(party_level)
	var multiplier = get_difficulty_multiplier(difficulty)

	return int(base_xp_per_player * party_size * multiplier)

func get_xp_per_player_by_level(level: int) -> int:
	"""Get base XP per player by level"""
	match level:
		1: return 200
		2: return 450
		3: return 700
		4: return 1100
		5: return 1800
		6: return 2300
		7: return 2900
		8: return 3900
		9: return 5000
		10: return 5900
		11: return 7200
		12: return 8400
		13: return 10000
		14: return 11500
		15: return 13000
		16: return 15000
		17: return 18000
		18: return 20000
		19: return 22000
		20: return 25000
		_: return 200

func get_difficulty_multiplier(difficulty: String) -> float:
	"""Get difficulty multiplier"""
	match difficulty.to_lower():
		"easy": return 0.5
		"medium": return 1.0
		"hard": return 1.5
		"deadly": return 2.0
		_: return 1.0

# Monster analysis and statistics

func get_monster_statistics() -> Dictionary:
	"""Get statistics about loaded monsters"""
	var stats = {
		"total_monsters": monsters.size(),
		"by_cr": {},
		"by_type": {},
		"by_size": {},
		"legendary_count": 0,
		"with_darkvision": 0,
		"total_xp_range": {"min": 0, "max": 0}
	}

	# Count by CR
	for cr in monsters_by_cr.keys():
		stats.by_cr[cr] = monsters_by_cr[cr].size()

	# Count by type
	for creature_type in monsters_by_type.keys():
		stats.by_type[creature_type] = monsters_by_type[creature_type].size()

	# Count by size
	for size in monsters_by_size.keys():
		stats.by_size[size] = monsters_by_size[size].size()

	# Count special features
	var min_xp = 999999
	var max_xp = 0

	for monster_resource in monsters.values():
		if monster_resource.is_legendary():
			stats.legendary_count += 1
		if monster_resource.has_darkvision():
			stats.with_darkvision += 1

		var xp = monster_resource.get_experience_points()
		min_xp = min(min_xp, xp)
		max_xp = max(max_xp, xp)

	stats.total_xp_range.min = min_xp
	stats.total_xp_range.max = max_xp

	return stats

func print_monster_summary() -> void:
	"""Print summary of loaded monsters"""
	var stats = get_monster_statistics()
	print("=== Monster Summary ===")
	print("Total monsters: " + str(stats.total_monsters))
	print("By CR: " + str(stats.by_cr))
	print("By type: " + str(stats.by_type))
	print("By size: " + str(stats.by_size))
	print("Legendary monsters: " + str(stats.legendary_count))
	print("With darkvision: " + str(stats.with_darkvision))
	print("XP range: " + str(stats.total_xp_range.min) + " - " + str(stats.total_xp_range.max))

# Monster recommendations

func get_monster_recommendations_for_encounter(party_level: int, party_size: int = 4) -> Dictionary:
	"""Get monster recommendations for an encounter"""
	var recommendations = {
		"easy": [],
		"medium": [],
		"hard": [],
		"deadly": []
	}

	for difficulty in recommendations.keys():
		var encounter = build_encounter(party_level, party_size, difficulty)
		recommendations[difficulty] = encounter

	return recommendations

func get_boss_monsters_for_level(level: int) -> Array[MonsterResource]:
	"""Get appropriate boss monsters for a given level"""
	var boss_monsters: Array[MonsterResource] = []

	# Boss monsters should be 2-4 levels above party level
	var min_cr = level + 2
	var max_cr = level + 4

	var candidates = get_monsters_by_cr_range(min_cr, max_cr)

	# Prefer legendary monsters for bosses
	for monster in candidates:
		if monster.is_legendary():
			boss_monsters.append(monster)

	# If no legendary monsters, add regular high-CR monsters
	if boss_monsters.is_empty():
		boss_monsters = candidates.slice(0, 5)  # Top 5 candidates

	return boss_monsters

# Helper functions

func _monster_resource_to_dict(monster_resource: MonsterResource) -> Dictionary:
	"""Convert MonsterResource to legacy Dictionary format"""
	return {
		"name": monster_resource.name,
		"size": monster_resource.size,
		"type": monster_resource.type,
		"alignment": monster_resource.alignment,
		"armor_class": monster_resource.armor_class,
		"hit_points": monster_resource.hit_points,
		"speed": monster_resource.speed,
		"abilities": monster_resource.abilities,
		"saving_throws": monster_resource.saving_throws,
		"skills": monster_resource.skills,
		"damage_immunities": monster_resource.damage_immunities,
		"damage_resistances": monster_resource.damage_resistances,
		"damage_vulnerabilities": monster_resource.damage_vulnerabilities,
		"condition_immunities": monster_resource.condition_immunities,
		"senses": monster_resource.senses,
		"languages": monster_resource.languages,
		"challenge_rating": monster_resource.challenge_rating,
		"xp": monster_resource.xp,
		"traits": monster_resource.traits,
		"actions": monster_resource.actions,
		"reactions": monster_resource.reactions,
		"legendary_actions": monster_resource.legendary_actions
	}
