extends Node

# Comprehensive equipment system with stat modifications and durability
# Now uses .tres Resource files for type safety

class_name EquipmentSystem

signal equipment_changed(character: Character)
signal item_equipped(item: EquipmentResource, slot: String)
signal item_unequipped(item: EquipmentResource, slot: String)
signal durability_changed(item: EquipmentResource, current_durability: int)

# Equipment slots
enum EquipmentSlot {
    HEAD,
    CHEST,
    HANDS,
    FEET,
    MAIN_HAND,
    OFF_HAND,
    RING_1,
    RING_2,
    NECKLACE,
    CLOAK
}

# Equipment sets for bonuses
var equipment_sets: Dictionary = {}
var equipped_items: Dictionary = {}
var current_character: Character
var equipment_manager: EquipmentResourceManager

func _init() -> void:
    equipment_manager = EquipmentResourceManager.new()
    add_child(equipment_manager)
    setup_equipment_sets()

func setup_equipment_sets() -> void:
    """Load equipment sets from resource manager"""
    # Wait for equipment manager to load data
    await equipment_manager.data_loaded if equipment_manager.has_method("data_loaded") else get_tree().process_frame

    # Get all equipment from the manager
    var all_equipment = equipment_manager.get_all_equipment()

    # Group equipment by sets (this would need to be implemented in the equipment data)
    # For now, we'll create a simple grouping based on equipment names
    for equipment_id in all_equipment.keys():
        var equipment_data = all_equipment[equipment_id]
        var set_name = equipment_data.get("set_name", "none")

        if set_name != "none":
            if not equipment_sets.has(set_name):
                equipment_sets[set_name] = []
            equipment_sets[set_name].append(equipment_data)

    print("Loaded " + str(equipment_sets.size()) + " equipment sets")

func equip_item(character: Character, item: EquipmentResource, slot: String) -> bool:
    """Equip an item to a character"""
    if not can_equip_item(character, item, slot):
        return false

    # Unequip existing item in slot
    if slot in equipped_items:
        unequip_item(character, slot)

    # Equip new item
    equipped_items[slot] = item
    self.current_character = character

    # Apply stat modifications
    apply_item_stats(character, item, true)

    # Check for set bonuses
    check_equipment_sets(character)

    item_equipped.emit(item, slot)
    equipment_changed.emit(character)

    return true

func unequip_item(character: Character, slot: String) -> bool:
    """Unequip an item from a character"""
    if slot not in equipped_items:
        return false

    var item = equipped_items[slot]

    # Remove stat modifications
    apply_item_stats(character, item, false)

    # Remove from equipped items
    equipped_items.erase(slot)
    self.current_character = character

    # Recheck set bonuses
    check_equipment_sets(character)

    item_unequipped.emit(item, slot)
    equipment_changed.emit(character)

    return true

func can_equip_item(character: Character, item: EquipmentResource, slot: String) -> bool:
    """Check if an item can be equipped"""
    # Check if slot is valid for item
    if slot not in item.equipment_slots:
        return false

    # Check strength requirements
    if item.strength_requirement > 0 and character.strength < item.strength_requirement:
        return false

    # Check attunement requirements
    if item.requires_attunement and not can_attune_item(character, item):
        return false

    # Check if slot is already occupied
    if slot in equipped_items:
        return false

    return true

func can_attune_item(_character: Character, _item: EquipmentResource) -> bool:
    """Check if character can attune to a magic item"""
    # Count current attuned items
    var attuned_count = 0
    for equipped_item in equipped_items.values():
        if equipped_item.requires_attunement:
            attuned_count += 1

    # Characters can attune to up to 3 items
    return attuned_count < 3

func apply_item_stats(_character: Character, item: EquipmentResource, equip: bool) -> void:
    """Apply or remove item stat modifications"""
    var multiplier = 1 if equip else -1

    # Apply ability score bonuses
    if item.has_method("get_ability_bonuses"):
        var bonuses = item.get_ability_bonuses()
        for ability in bonuses:
            var _bonus = bonuses[ability] * multiplier
            # This would modify character stats
            # character.add_ability_bonus(ability, bonus)

    # Apply skill bonuses
    if item.has_method("get_skill_bonuses"):
        var bonuses = item.get_skill_bonuses()
        for skill in bonuses:
            var _bonus = bonuses[skill] * multiplier
            # character.add_skill_bonus(skill, bonus)

    # Apply saving throw bonuses
    if item.has_method("get_saving_throw_bonuses"):
        var bonuses = item.get_saving_throw_bonuses()
        for save in bonuses:
            var _bonus = bonuses[save] * multiplier
            # character.add_saving_throw_bonus(save, bonus)

func check_equipment_sets(character: Character) -> void:
    """Check for equipment set bonuses"""
    var active_sets = get_active_equipment_sets()

    for set_name_value in active_sets:
        var set_data = equipment_sets[set_name_value]
        apply_set_bonuses(character, set_data, true)

func get_active_equipment_sets() -> Array[String]:
    """Get currently active equipment sets"""
    var active_sets = []
    var equipped_item_names = []

    for item in equipped_items.values():
        equipped_item_names.append(item.item_name)

    for set_name_value in equipment_sets:
        var set_data = equipment_sets[set_name_value]
        var pieces = set_data.pieces
        var has_all_pieces = true

        for piece in pieces:
            if piece not in equipped_item_names:
                has_all_pieces = false
                break

        if has_all_pieces:
            active_sets.append(set_name)

    return active_sets

func apply_set_bonuses(_character: Character, set_data: Dictionary, apply: bool) -> void:
    """Apply or remove equipment set bonuses"""
    var multiplier = 1 if apply else -1
    var bonuses = set_data.bonuses

    for bonus_type in bonuses:
        var _bonus_value = bonuses[bonus_type] * multiplier
        # Apply the bonus to character
        # This would be implemented based on the bonus type

func get_equipped_item(slot: String) -> EquipmentResource:
    """Get the item equipped in a specific slot"""
    return equipped_items.get(slot, null)

func get_all_equipped_items() -> Dictionary:
    """Get all currently equipped items"""
    return equipped_items.duplicate()

func get_equipment_bonus(stat_name: String) -> int:
    """Get total equipment bonus for a specific stat"""
    var total_bonus = 0

    for item in equipped_items.values():
        if item.has_method("get_stat_bonus"):
            total_bonus += item.get_stat_bonus(stat_name)

    return total_bonus

func get_armor_class_bonus(_character: Character) -> int:
    """Calculate total armor class bonus from equipment"""
    var ac_bonus = 0

    for item in equipped_items.values():
        if item.is_armor():
            ac_bonus += item.armor_class
        elif item.item_type == EquipmentResource.EquipmentType.SHIELD:
            ac_bonus += item.armor_class

    return ac_bonus

func get_weapon_bonus(_character: Character) -> int:
    """Calculate total weapon attack bonus from equipment"""
    var weapon_bonus = 0

    for item in equipped_items.values():
        if item.is_weapon():
            if item.has_method("get_attack_bonus"):
                weapon_bonus += item.get_attack_bonus()

    return weapon_bonus

func get_damage_bonus(_character: Character) -> int:
    """Calculate total damage bonus from equipment"""
    var damage_bonus = 0

    for item in equipped_items.values():
        if item.is_weapon():
            if item.has_method("get_damage_bonus"):
                damage_bonus += item.get_damage_bonus()

    return damage_bonus

func get_equipment_weight() -> float:
    """Calculate total weight of equipped items"""
    var total_weight = 0.0

    for item in equipped_items.values():
        total_weight += item.weight

    return total_weight

func get_equipment_value() -> int:
    """Calculate total value of equipped items"""
    var total_value = 0

    for item in equipped_items.values():
        total_value += item.cost

    return total_value

func repair_item(item: EquipmentResource, repair_amount: int):
    """Repair an item's durability"""
    if item.has_method("repair"):
        item.repair(repair_amount)
        durability_changed.emit(item, item.get_current_durability())

func damage_item(item: EquipmentResource, damage_amount: int):
    """Damage an item's durability"""
    if item.has_method("take_damage"):
        item.take_damage(damage_amount)
        durability_changed.emit(item, item.get_current_durability())

func is_item_broken(item: EquipmentResource) -> bool:
    """Check if an item is broken"""
    if item.has_method("is_broken"):
        return item.is_broken()
    return item.current_durability <= 0

# New Resource-based functions

func get_equipment_recommendations_for_character(character: Character) -> Dictionary:
    """Get equipment recommendations for a character using Resources"""
    return equipment_manager.get_equipment_recommendations_for_character(character)

func search_equipment(query: String) -> Array[EquipmentResource]:
    """Search equipment by name or description using Resources"""
    return equipment_manager.search_equipment(query)

func get_equipment_by_type(item_type: EquipmentResource.EquipmentType) -> Array[EquipmentResource]:
    """Get equipment by type using Resources"""
    return equipment_manager.get_equipment_by_type(item_type)

func get_equipment_by_rarity(rarity: String) -> Array[EquipmentResource]:
    """Get equipment by rarity using Resources"""
    return equipment_manager.get_equipment_by_rarity(rarity)

func create_equipment_from_template(template_name: String, modifications: Dictionary = {}) -> EquipmentResource:
    """Create equipment from a template with modifications using Resources"""
    return equipment_manager.create_equipment_from_template(template_name, modifications)

func upgrade_equipment(equipment_resource: EquipmentResource, upgrade_type: String) -> EquipmentResource:
    """Upgrade equipment with a specific upgrade type using Resources"""
    return equipment_manager.upgrade_equipment(equipment_resource, upgrade_type)

func get_equipment_statistics() -> Dictionary:
    """Get statistics about loaded equipment using Resources"""
    return equipment_manager.get_equipment_statistics()

func print_equipment_summary() -> void:
    """Print summary of loaded equipment using Resources"""
    equipment_manager.print_equipment_summary()

# Equipment validation and analysis

func validate_equipment_loadout(character: Character) -> Dictionary:
    """Validate a character's equipment loadout"""
    var validation = {
        "valid": true,
        "warnings": [],
        "errors": [],
        "recommendations": []
    }

    # Check for duplicate equipment slots
    var used_slots = {}
    for slot in equipped_items.keys():
        if used_slots.has(slot):
            validation.errors.append("Duplicate equipment in slot: " + slot)
            validation.valid = false
        used_slots[slot] = true

    # Check strength requirements
    for item in equipped_items.values():
        if item.strength_requirement > 0 and character.strength < item.strength_requirement:
            validation.warnings.append("Item " + item.item_name + " requires more strength")

    # Check weight limits
    var total_weight = get_equipment_weight()
    var max_carry_weight = character.strength * 15  # Standard D&D carry capacity
    if total_weight > max_carry_weight:
        validation.warnings.append("Equipment weight exceeds carry capacity")

    # Check for missing essential equipment
    if not equipped_items.has("MAIN_HAND"):
        validation.recommendations.append("Consider equipping a weapon")

    if not equipped_items.has("CHEST"):
        validation.recommendations.append("Consider equipping armor")

    return validation

func optimize_equipment_for_character(character: Character) -> Dictionary:
    """Get optimized equipment recommendations for a character"""
    var recommendations = get_equipment_recommendations_for_character(character)
    var optimization = {
        "current_loadout_value": get_equipment_value(),
        "current_loadout_weight": get_equipment_weight(),
        "recommended_weapons": recommendations.weapons.slice(0, 3),  # Top 3
        "recommended_armor": recommendations.armor.slice(0, 3),  # Top 3
        "recommended_accessories": recommendations.accessories.slice(0, 3),  # Top 3
        "improvement_suggestions": []
    }

    # Analyze current equipment and suggest improvements
    var current_weapons = []
    var current_armor = []

    for item in equipped_items.values():
        if item.is_weapon():
            current_weapons.append(item)
        elif item.is_armor():
            current_armor.append(item)

    # Suggest weapon upgrades
    if current_weapons.size() > 0:
        var current_weapon = current_weapons[0]
        for recommended_weapon in recommendations.weapons:
            if recommended_weapon.cost > current_weapon.cost and recommended_weapon.attack_bonus > current_weapon.attack_bonus:
                optimization.improvement_suggestions.append("Upgrade weapon to " + recommended_weapon.item_name)
                break

    # Suggest armor upgrades
    if current_armor.size() > 0:
        var current_armor_item = current_armor[0]
        for recommended_armor in recommendations.armor:
            if recommended_armor.cost > current_armor_item.cost and recommended_armor.armor_class > current_armor_item.armor_class:
                optimization.improvement_suggestions.append("Upgrade armor to " + recommended_armor.item_name)
                break

    return optimization

func get_equipment_summary(_character: Character) -> Dictionary:
    """Get a summary of all equipment effects"""
    return {
        "armor_class_bonus": get_armor_class_bonus(_character),
        "weapon_bonus": get_weapon_bonus(_character),
        "damage_bonus": get_damage_bonus(_character),
        "total_weight": get_equipment_weight(),
        "total_value": get_equipment_value(),
        "active_sets": get_active_equipment_sets(),
        "equipped_items": get_all_equipped_items()
    }
