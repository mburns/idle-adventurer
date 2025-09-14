extends Node

# Comprehensive equipment system with stat modifications and durability

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
var yaml_parser: YAMLParser

func _init() -> void:
    yaml_parser = YAMLParser.new()
    setup_equipment_sets()

func setup_equipment_sets() -> void:
    """Load equipment sets from data file"""
    var file_path = "res://data/equipment/sets.yaml"
    var equipment_data = yaml_parser.parse_yaml_file(file_path)

    if equipment_data.is_empty():
        print("Error: Could not load equipment sets from " + file_path)
        return

    var sets_data = equipment_data.get("equipment_sets", [])
    for set_data in sets_data:
        var set_id = set_data.get("id", "")
        var set_name_value = set_data.get("name", "")
        if set_id != "" and set_name_value != "":
            equipment_sets[set_name_value] = {
                "pieces": set_data.get("pieces", []),
                "bonuses": set_data.get("bonuses", {}),
                "description": set_data.get("description", ""),
                "rarity": set_data.get("rarity", "common")
            }

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
    return false

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
