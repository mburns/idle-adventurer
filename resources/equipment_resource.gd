class_name EquipmentResource
extends Resource

# D&D Equipment as a Godot Resource for better editor integration

enum EquipmentType {
    WEAPON,
    ARMOR,
    SHIELD,
    TOOL,
    ADVENTURING_GEAR,
    MAGIC_ITEM,
    CONSUMABLE
}

enum WeaponType {
    MELEE,
    RANGED,
    THROWN
}

enum ArmorType {
    LIGHT,
    MEDIUM,
    HEAVY,
    SHIELD
}

@export var item_name: String = ""
@export var item_type: EquipmentType = EquipmentType.ADVENTURING_GEAR
@export var cost: int = 0
@export var weight: float = 0.0
@export var description: String = ""
@export var rarity: String = "common"

# Weapon properties
@export var weapon_type: WeaponType = WeaponType.MELEE
@export var damage_dice: String = "1d4"
@export var damage_type: String = "bludgeoning"
@export var properties: Array[String] = []
@export var range_normal: int = 0
@export var range_long: int = 0
@export var finesse: bool = false
@export var two_handed: bool = false
@export var versatile: bool = false
@export var ammunition: bool = false

# Armor properties
@export var armor_type: ArmorType = ArmorType.LIGHT
@export var armor_class: int = 10
@export var strength_requirement: int = 0
@export var stealth_disadvantage: bool = false

# Magic item properties
@export var requires_attunement: bool = false
@export var attunement_requirements: String = ""
@export var charges: int = 0
@export var recharge_rate: String = ""

# Equipment slots
@export var equipment_slots: Array[String] = []
@export var stackable: bool = false
@export var max_stack_size: int = 1

# Crafting and economy
@export var crafting_materials: Array[String] = []
@export var crafting_time: int = 0  # in hours
@export var sell_value: int = 0  # typically cost / 2

# Stat modifications
@export var ability_bonuses: Dictionary = {}  # {"strength": 2, "dexterity": 1}
@export var skill_bonuses: Dictionary = {}  # {"athletics": 1, "stealth": 2}
@export var saving_throw_bonuses: Dictionary = {}  # {"strength": 1, "constitution": 1}
@export var attack_bonus: int = 0
@export var damage_bonus: int = 0
@export var armor_class_bonus: int = 0

# Durability system
@export var max_durability: int = 100
@export var current_durability: int = 100
@export var durability_loss_rate: float = 1.0  # How fast it degrades
@export var repair_cost_multiplier: float = 0.1  # Cost to repair as fraction of item cost

func get_cost_in_gold() -> float:
    return cost / 100.0  # Assuming cost is in copper pieces

func get_weight_in_pounds() -> float:
    return weight

func is_weapon() -> bool:
    return item_type == EquipmentType.WEAPON

func is_armor() -> bool:
    return item_type == EquipmentType.ARMOR

func is_magic_item() -> bool:
    return item_type == EquipmentType.MAGIC_ITEM

func is_consumable() -> bool:
    return item_type == EquipmentType.CONSUMABLE

func can_be_used_with_two_weapons() -> bool:
    return is_weapon() and "light" in properties

func requires_ammunition() -> bool:
    return ammunition

func get_effective_armor_class(dex_modifier: int) -> int:
    if not is_armor():
        return 10 + dex_modifier

    match armor_type:
        ArmorType.LIGHT:
            return armor_class + dex_modifier
        ArmorType.MEDIUM:
            return armor_class + min(dex_modifier, 2)
        ArmorType.HEAVY:
            return armor_class
        ArmorType.SHIELD:
            return armor_class
        _:
            return armor_class

func get_damage_roll() -> String:
    if not is_weapon():
        return "1d4"
    return damage_dice

func get_equipment_properties() -> Array[String]:
    return properties

func has_property(property: String) -> bool:
    return property in properties

func get_rarity_color() -> Color:
    match rarity.to_lower():
        "common":
            return Color.WHITE
        "uncommon":
            return Color.GREEN
        "rare":
            return Color.BLUE
        "very rare":
            return Color.PURPLE
        "legendary":
            return Color.ORANGE
        "artifact":
            return Color.GOLD
        _:
            return Color.WHITE

func get_equipment_slot_icon() -> String:
    if "head" in equipment_slots:
        return "helmet"
    elif "chest" in equipment_slots:
        return "armor"
    elif "hands" in equipment_slots:
        return "gloves"
    elif "feet" in equipment_slots:
        return "boots"
    elif "main_hand" in equipment_slots:
        return "sword"
    elif "off_hand" in equipment_slots:
        return "shield"
    else:
        return "item"

# Stat modification methods
func get_ability_bonuses() -> Dictionary:
    return ability_bonuses.duplicate()

func get_skill_bonuses() -> Dictionary:
    return skill_bonuses.duplicate()

func get_saving_throw_bonuses() -> Dictionary:
    return saving_throw_bonuses.duplicate()

func get_stat_bonus(stat_name: String) -> int:
    """Get bonus for a specific stat"""
    if stat_name in ability_bonuses:
        return ability_bonuses[stat_name]
    elif stat_name in skill_bonuses:
        return skill_bonuses[stat_name]
    elif stat_name in saving_throw_bonuses:
        return saving_throw_bonuses[stat_name]
    return 0

func get_attack_bonus() -> int:
    return attack_bonus

func get_damage_bonus() -> int:
    return damage_bonus

# Durability methods
func get_current_durability() -> int:
    return current_durability

func get_max_durability() -> int:
    return max_durability

func get_durability_percentage() -> float:
    if max_durability <= 0:
        return 100.0
    return (float(current_durability) / float(max_durability)) * 100.0

func is_broken() -> bool:
    return current_durability <= 0

func is_damaged() -> bool:
    return current_durability < max_durability

func take_damage(damage_amount: int):
    """Take durability damage"""
    current_durability = max(0, current_durability - damage_amount)

func repair(repair_amount: int):
    """Repair durability"""
    current_durability = min(max_durability, current_durability + repair_amount)

func get_repair_cost() -> int:
    """Calculate cost to fully repair item"""
    var damage = max_durability - current_durability
    return int(damage * repair_cost_multiplier * cost)

func get_effective_stats() -> Dictionary:
    """Get effective stats considering durability"""
    var effectiveness = get_durability_percentage() / 100.0
    var effective_stats = {}

    # Reduce bonuses based on durability
    for ability in ability_bonuses:
        effective_stats[ability] = int(ability_bonuses[ability] * effectiveness)

    for skill in skill_bonuses:
        effective_stats[skill] = int(skill_bonuses[skill] * effectiveness)

    for save in saving_throw_bonuses:
        effective_stats[save] = int(saving_throw_bonuses[save] * effectiveness)

    effective_stats["attack_bonus"] = int(attack_bonus * effectiveness)
    effective_stats["damage_bonus"] = int(damage_bonus * effectiveness)
    effective_stats["armor_class_bonus"] = int(armor_class_bonus * effectiveness)

    return effective_stats

func get_condition_description() -> String:
    """Get a description of the item's condition"""
    var percentage = get_durability_percentage()

    if percentage >= 100:
        return "Pristine"
    elif percentage >= 80:
        return "Excellent"
    elif percentage >= 60:
        return "Good"
    elif percentage >= 40:
        return "Fair"
    elif percentage >= 20:
        return "Poor"
    elif percentage > 0:
        return "Damaged"
    else:
        return "Broken"

func get_condition_color() -> Color:
    """Get color representing the item's condition"""
    var percentage = get_durability_percentage()

    if percentage >= 80:
        return Color.GREEN
    elif percentage >= 60:
        return Color.YELLOW
    elif percentage >= 40:
        return Color.ORANGE
    elif percentage > 0:
        return Color.RED
    else:
        return Color.GRAY
