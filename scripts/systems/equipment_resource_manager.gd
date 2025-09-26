extends Node

# Equipment Resource Manager
# Manages equipment using .tres Resource files for type safety

class_name EquipmentResourceManager

# Resource storage
var equipment: Dictionary = {} # item_name -> EquipmentResource
var equipment_by_type: Dictionary = {} # EquipmentType -> Array[EquipmentResource]
var equipment_by_rarity: Dictionary = {} # rarity -> Array[EquipmentResource]
var equipment_by_slot: Dictionary = {} # slot -> Array[EquipmentResource]

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
		

	load_all_equipment()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Load all equipment from .tres files
func load_all_equipment() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Wait for data loader to finish loading
	await data_loader.data_loaded

	# Get equipment from data loader
	var all_equipment = data_loader.get_all_equipment()

	# Populate our storage
	for equipment_resource in all_equipment:
		equipment[equipment_resource.name] = equipment_resource

	# Organize equipment by various criteria
	organize_equipment()

	print("Loaded " + str(equipment.size()) + " equipment resources")


# Organize equipment by various criteria
func organize_equipment() -> void:
	# Clear existing organization
	equipment_by_type.clear()
	equipment_by_rarity.clear()
	equipment_by_slot.clear()

	# Initialize arrays for each type
	for type_enum in EquipmentResource.EquipmentType.values():
		equipment_by_type[type_enum] = []

	# Organize equipment
	for equipment_resource in equipment.values():
		# By type
		var item_type = equipment_resource.item_type
		if equipment_by_type.has(item_type):
			equipment_by_type[item_type].append(equipment_resource)

		# By rarity
		var rarity = equipment_resource.rarity.to_lower()
		if not equipment_by_rarity.has(rarity):
			equipment_by_rarity[rarity] = []
		equipment_by_rarity[rarity].append(equipment_resource)

		# By equipment slots
		for slot in equipment_resource.equipment_slots:
			if not equipment_by_slot.has(slot):
				equipment_by_slot[slot] = []
			equipment_by_slot[slot].append(equipment_resource)

# Public API

func get_equipment(item_name: String) -> EquipmentResource:
	"""Get equipment resource by name"""
	return equipment.get(item_name, null)

func get_all_equipment() -> Array[EquipmentResource]:
	"""Get all equipment resources"""
	var all_equipment: Array[EquipmentResource] = []
	for equipment_resource in equipment.values():
		all_equipment.append(equipment_resource)
	return all_equipment

func get_equipment_by_type(item_type: EquipmentResource.EquipmentType) -> Array[EquipmentResource]:
	"""Get all equipment of a specific type"""
	return equipment_by_type.get(item_type, [])

func get_equipment_by_rarity(rarity: String) -> Array[EquipmentResource]:
	"""Get all equipment of a specific rarity"""
	return equipment_by_rarity.get(rarity.to_lower(), [])

func get_equipment_for_slot(slot: String) -> Array[EquipmentResource]:
	"""Get all equipment that can be equipped in a specific slot"""
	return equipment_by_slot.get(slot, [])

func get_weapons() -> Array[EquipmentResource]:
	"""Get all weapons"""
	return get_equipment_by_type(EquipmentResource.EquipmentType.WEAPON)

func get_armor() -> Array[EquipmentResource]:
	"""Get all armor"""
	return get_equipment_by_type(EquipmentResource.EquipmentType.ARMOR)

func get_magic_items() -> Array[EquipmentResource]:
	"""Get all magic items"""
	return get_equipment_by_type(EquipmentResource.EquipmentType.MAGIC_ITEM)

func get_consumables() -> Array[EquipmentResource]:
	"""Get all consumable items"""
	return get_equipment_by_type(EquipmentResource.EquipmentType.CONSUMABLE)

# Equipment filtering and search

func search_equipment(query: String) -> Array[EquipmentResource]:
	"""Search equipment by name or description"""
	var results: Array[EquipmentResource] = []
	var query_lower = query.to_lower()

	for equipment_resource in equipment.values():
		if equipment_resource.item_name.to_lower().contains(query_lower) or \
		   equipment_resource.description.to_lower().contains(query_lower):
			results.append(equipment_resource)

	return results

func filter_equipment_by_cost(min_cost: int, max_cost: int) -> Array[EquipmentResource]:
	"""Filter equipment by cost range"""
	var results: Array[EquipmentResource] = []

	for equipment_resource in equipment.values():
		if equipment_resource.cost >= min_cost and equipment_resource.cost <= max_cost:
			results.append(equipment_resource)

	return results

func filter_equipment_by_weight(max_weight: float) -> Array[EquipmentResource]:
	"""Filter equipment by maximum weight"""
	var results: Array[EquipmentResource] = []

	for equipment_resource in equipment.values():
		if equipment_resource.weight <= max_weight:
			results.append(equipment_resource)

	return results

func get_equipment_for_character(character: Character) -> Array[EquipmentResource]:
	"""Get equipment suitable for a character based on their class and level"""
	var suitable_equipment: Array[EquipmentResource] = []

	for equipment_resource in equipment.values():
		if is_equipment_suitable_for_character(character, equipment_resource):
			suitable_equipment.append(equipment_resource)

	return suitable_equipment

func is_equipment_suitable_for_character(character: Character, equipment_resource: EquipmentResource) -> bool:
	"""Check if equipment is suitable for a character"""
	# Check strength requirements
	if equipment_resource.strength_requirement > 0 and character.strength < equipment_resource.strength_requirement:
		return false

	# Check class restrictions (if any)
	# This would be implemented based on your class restriction system

	# Check level requirements (if any)
	# This would be implemented based on your level requirement system

	return true

# Equipment creation and modification

func create_equipment_from_template(template_name: String, modifications: Dictionary = {}) -> EquipmentResource:
	"""Create equipment from a template with modifications"""
	var template = get_equipment(template_name)
	if template == null:
		print("Template not found: " + template_name)
		return null

	# Create a copy of the template
	var new_equipment = EquipmentResource.new()

	# Copy all properties from template
	new_equipment.item_name = template.item_name
	new_equipment.item_type = template.item_type
	new_equipment.cost = template.cost
	new_equipment.weight = template.weight
	new_equipment.description = template.description
	new_equipment.rarity = template.rarity
	new_equipment.weapon_type = template.weapon_type
	new_equipment.damage_dice = template.damage_dice
	new_equipment.damage_type = template.damage_type
	new_equipment.properties = template.properties.duplicate()
	new_equipment.range_normal = template.range_normal
	new_equipment.range_long = template.range_long
	new_equipment.finesse = template.finesse
	new_equipment.two_handed = template.two_handed
	new_equipment.versatile = template.versatile
	new_equipment.ammunition = template.ammunition
	new_equipment.armor_type = template.armor_type
	new_equipment.armor_class = template.armor_class
	new_equipment.strength_requirement = template.strength_requirement
	new_equipment.stealth_disadvantage = template.stealth_disadvantage
	new_equipment.requires_attunement = template.requires_attunement
	new_equipment.attunement_requirements = template.attunement_requirements
	new_equipment.charges = template.charges
	new_equipment.recharge_rate = template.recharge_rate
	new_equipment.equipment_slots = template.equipment_slots.duplicate()
	new_equipment.stackable = template.stackable
	new_equipment.max_stack_size = template.max_stack_size
	new_equipment.crafting_materials = template.crafting_materials.duplicate()
	new_equipment.crafting_time = template.crafting_time
	new_equipment.sell_value = template.sell_value
	new_equipment.ability_bonuses = template.ability_bonuses.duplicate()
	new_equipment.skill_bonuses = template.skill_bonuses.duplicate()
	new_equipment.saving_throw_bonuses = template.saving_throw_bonuses.duplicate()
	new_equipment.attack_bonus = template.attack_bonus
	new_equipment.damage_bonus = template.damage_bonus
	new_equipment.armor_class_bonus = template.armor_class_bonus
	new_equipment.max_durability = template.max_durability
	new_equipment.current_durability = template.current_durability
	new_equipment.durability_loss_rate = template.durability_loss_rate
	new_equipment.repair_cost_multiplier = template.repair_cost_multiplier

	# Apply modifications
	for key in modifications.keys():
		if new_equipment.has_method("set_" + key):
			new_equipment.call("set_" + key, modifications[key])
		elif new_equipment.has(key):
			new_equipment.set(key, modifications[key])

	return new_equipment

func upgrade_equipment(equipment_resource: EquipmentResource, upgrade_type: String) -> EquipmentResource:
	"""Upgrade equipment with a specific upgrade type"""
	var upgrades = {
		"enhanced": {"attack_bonus": 1, "damage_bonus": 1},
		"reinforced": {"armor_class_bonus": 1, "max_durability": 50},
		"magical": {"requires_attunement": true, "charges": 3},
		"masterwork": {"cost": equipment_resource.cost * 2, "rarity": "rare"}
	}

	if not upgrades.has(upgrade_type):
		print("Unknown upgrade type: " + upgrade_type)
		return equipment_resource

	var modifications = upgrades[upgrade_type]
	return create_equipment_from_template(equipment_resource.item_name, modifications)

# Equipment analysis and statistics

func get_equipment_statistics() -> Dictionary:
	"""Get statistics about loaded equipment"""
	var stats = {
		"total_equipment": equipment.size(),
		"by_type": {},
		"by_rarity": {},
		"by_slot": {},
		"total_value": 0,
		"total_weight": 0.0
	}

	# Count by type
	for type_enum in EquipmentResource.EquipmentType.values():
		stats.by_type[type_enum] = equipment_by_type.get(type_enum, []).size()

	# Count by rarity
	for rarity in equipment_by_rarity.keys():
		stats.by_rarity[rarity] = equipment_by_rarity[rarity].size()

	# Count by slot
	for slot in equipment_by_slot.keys():
		stats.by_slot[slot] = equipment_by_slot[slot].size()

	# Calculate totals
	for equipment_resource in equipment.values():
		stats.total_value += equipment_resource.cost
		stats.total_weight += equipment_resource.weight

	return stats

func print_equipment_summary() -> void:
	"""Print summary of loaded equipment"""
	var stats = get_equipment_statistics()
	print("=== Equipment Summary ===")
	print("Total equipment: " + str(stats.total_equipment))
	print("By type: " + str(stats.by_type))
	print("By rarity: " + str(stats.by_rarity))
	print("By slot: " + str(stats.by_slot))
	print("Total value: " + str(stats.total_value) + " copper pieces")
	print("Total weight: " + str(stats.total_weight) + " pounds")

# Equipment recommendations

func get_equipment_recommendations_for_character(character: Character) -> Dictionary:
	"""Get equipment recommendations for a character"""
	var recommendations = {
		"weapons": [],
		"armor": [],
		"accessories": [],
		"consumables": []
	}

	# Get suitable equipment
	var suitable_equipment = get_equipment_for_character(character)

	# Categorize recommendations
	for equipment_resource in suitable_equipment:
		if equipment_resource.is_weapon():
			recommendations.weapons.append(equipment_resource)
		elif equipment_resource.is_armor():
			recommendations.armor.append(equipment_resource)
		elif equipment_resource.is_magic_item():
			recommendations.accessories.append(equipment_resource)
		elif equipment_resource.is_consumable():
			recommendations.consumables.append(equipment_resource)

	# Sort by value/usefulness
	recommendations.weapons.sort_custom(func(a, b): return a.cost > b.cost)
	recommendations.armor.sort_custom(func(a, b): return a.armor_class > b.armor_class)
	recommendations.accessories.sort_custom(func(a, b): return a.cost > b.cost)
	recommendations.consumables.sort_custom(func(a, b): return a.cost > b.cost)

	return recommendations

# Helper functions

func _equipment_resource_to_dict(equipment_resource: EquipmentResource) -> Dictionary:
	"""Convert EquipmentResource to legacy Dictionary format"""
	return {
		"name": equipment_resource.item_name,
		"type": equipment_resource.item_type,
		"cost": equipment_resource.cost,
		"weight": equipment_resource.weight,
		"description": equipment_resource.description,
		"rarity": equipment_resource.rarity,
		"weapon_type": equipment_resource.weapon_type,
		"damage_dice": equipment_resource.damage_dice,
		"damage_type": equipment_resource.damage_type,
		"properties": equipment_resource.properties,
		"range_normal": equipment_resource.range_normal,
		"range_long": equipment_resource.range_long,
		"finesse": equipment_resource.finesse,
		"two_handed": equipment_resource.two_handed,
		"versatile": equipment_resource.versatile,
		"ammunition": equipment_resource.ammunition,
		"armor_type": equipment_resource.armor_type,
		"armor_class": equipment_resource.armor_class,
		"strength_requirement": equipment_resource.strength_requirement,
		"stealth_disadvantage": equipment_resource.stealth_disadvantage,
		"requires_attunement": equipment_resource.requires_attunement,
		"attunement_requirements": equipment_resource.attunement_requirements,
		"charges": equipment_resource.charges,
		"recharge_rate": equipment_resource.recharge_rate,
		"equipment_slots": equipment_resource.equipment_slots,
		"stackable": equipment_resource.stackable,
		"max_stack_size": equipment_resource.max_stack_size,
		"crafting_materials": equipment_resource.crafting_materials,
		"crafting_time": equipment_resource.crafting_time,
		"sell_value": equipment_resource.sell_value,
		"ability_bonuses": equipment_resource.ability_bonuses,
		"skill_bonuses": equipment_resource.skill_bonuses,
		"saving_throw_bonuses": equipment_resource.saving_throw_bonuses,
		"attack_bonus": equipment_resource.attack_bonus,
		"damage_bonus": equipment_resource.damage_bonus,
		"armor_class_bonus": equipment_resource.armor_class_bonus,
		"max_durability": equipment_resource.max_durability,
		"current_durability": equipment_resource.current_durability,
		"durability_loss_rate": equipment_resource.durability_loss_rate,
		"repair_cost_multiplier": equipment_resource.repair_cost_multiplier
	}
