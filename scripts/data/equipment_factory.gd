extends Node

# Factory for creating equipment items with proper stats

class_name EquipmentFactory

static func create_sword() -> EquipmentResource:
    """Create a basic sword"""
    var sword = EquipmentResource.new()
    sword.item_name = "Longsword"
    sword.item_type = EquipmentResource.EquipmentType.WEAPON
    sword.cost = 1500  # 15 gold
    sword.weight = 3.0
    sword.description = "A well-balanced sword, perfect for combat."
    sword.rarity = "common"

    # Weapon properties
    sword.weapon_type = EquipmentResource.WeaponType.MELEE
    sword.damage_dice = "1d8"
    sword.damage_type = "slashing"
    sword.properties = ["versatile"]
    sword.versatile = true
    sword.range_normal = 5
    sword.range_long = 0

    # Equipment slots
    sword.equipment_slots = ["main_hand"]

    # Stat bonuses
    sword.attack_bonus = 0
    sword.damage_bonus = 0

    # Durability
    sword.max_durability = 100
    sword.current_durability = 100
    sword.durability_loss_rate = 1.0
    sword.repair_cost_multiplier = 0.1

    return sword

static func create_chain_mail() -> EquipmentResource:
    """Create chain mail armor"""
    var armor = EquipmentResource.new()
    armor.item_name = "Chain Mail"
    armor.item_type = EquipmentResource.EquipmentType.ARMOR
    armor.cost = 7500  # 75 gold
    armor.weight = 55.0
    armor.description = "Heavy armor made of interlocking metal rings."
    armor.rarity = "common"

    # Armor properties
    armor.armor_type = EquipmentResource.ArmorType.MEDIUM
    armor.armor_class = 16
    armor.strength_requirement = 13
    armor.stealth_disadvantage = true

    # Equipment slots
    armor.equipment_slots = ["chest"]

    # Stat bonuses
    armor.armor_class_bonus = 6  # 16 - 10 base

    # Durability
    armor.max_durability = 120
    armor.current_durability = 120
    armor.durability_loss_rate = 0.8  # Armor degrades slower
    armor.repair_cost_multiplier = 0.15

    return armor

static func create_ring_of_protection() -> EquipmentResource:
    """Create a ring of protection"""
    var ring = EquipmentResource.new()
    ring.item_name = "Ring of Protection"
    ring.item_type = EquipmentResource.EquipmentType.MAGIC_ITEM
    ring.cost = 40000  # 400 gold
    ring.weight = 0.0
    ring.description = "A magical ring that provides protection from harm."
    ring.rarity = "uncommon"

    # Magic item properties
    ring.requires_attunement = true
    ring.attunement_requirements = ""

    # Equipment slots
    ring.equipment_slots = ["ring_1", "ring_2"]

    # Stat bonuses
    ring.armor_class_bonus = 1
    ring.saving_throw_bonuses = {
        "strength": 1,
        "dexterity": 1,
        "constitution": 1,
        "intelligence": 1,
        "wisdom": 1,
        "charisma": 1
    }

    # Durability (magic items don't degrade)
    ring.max_durability = 1000
    ring.current_durability = 1000
    ring.durability_loss_rate = 0.0
    ring.repair_cost_multiplier = 0.0

    return ring

static func create_gloves_of_dexterity() -> EquipmentResource:
    """Create gloves that boost dexterity"""
    var gloves = EquipmentResource.new()
    gloves.item_name = "Gloves of Dexterity"
    gloves.item_type = EquipmentResource.EquipmentType.MAGIC_ITEM
    gloves.cost = 25000  # 250 gold
    gloves.weight = 0.5
    gloves.description = "Magical gloves that enhance the wearer's dexterity."
    gloves.rarity = "uncommon"

    # Magic item properties
    gloves.requires_attunement = true
    gloves.attunement_requirements = ""

    # Equipment slots
    gloves.equipment_slots = ["hands"]

    # Stat bonuses
    gloves.ability_bonuses = {"dexterity": 2}
    gloves.skill_bonuses = {
        "acrobatics": 1,
        "sleight_of_hand": 1,
        "stealth": 1
    }

    # Durability
    gloves.max_durability = 200
    gloves.current_durability = 200
    gloves.durability_loss_rate = 0.5
    gloves.repair_cost_multiplier = 0.2

    return gloves

static func create_health_potion() -> EquipmentResource:
    """Create a health potion"""
    var potion = EquipmentResource.new()
    potion.item_name = "Potion of Healing"
    potion.item_type = EquipmentResource.EquipmentType.CONSUMABLE
    potion.cost = 500  # 5 gold
    potion.weight = 0.5
    potion.description = "A magical potion that restores health when consumed."
    potion.rarity = "common"

    # Consumable properties
    potion.stackable = true
    potion.max_stack_size = 10

    # Equipment slots (consumables go in inventory)
    potion.equipment_slots = []

    # Durability (consumables don't have durability)
    potion.max_durability = 1
    potion.current_durability = 1
    potion.durability_loss_rate = 0.0
    potion.repair_cost_multiplier = 0.0

    return potion

static func create_equipment_set(set_name: String) -> Array[EquipmentResource]:
    """Create a complete equipment set"""
    match set_name.to_lower():
        "leather_armor_set":
            return [
                create_leather_armor(),
                create_leather_boots(),
                create_leather_gloves()
            ]
        "chain_mail_set":
            return [
                create_chain_mail(),
                create_chain_boots(),
                create_chain_gauntlets()
            ]
        "wizard_set":
            return [
                create_wizard_robe(),
                create_wizard_hat(),
                create_wizard_staff()
            ]
        _:
            return []

static func create_leather_armor() -> EquipmentResource:
    """Create leather armor"""
    var armor = EquipmentResource.new()
    armor.item_name = "Leather Armor"
    armor.item_type = EquipmentResource.EquipmentType.ARMOR
    armor.cost = 1000  # 10 gold
    armor.weight = 10.0
    armor.description = "Light armor made of tough leather."
    armor.rarity = "common"

    armor.armor_type = EquipmentResource.ArmorType.LIGHT
    armor.armor_class = 11
    armor.strength_requirement = 0
    armor.stealth_disadvantage = false

    armor.equipment_slots = ["chest"]
    armor.armor_class_bonus = 1
    armor.skill_bonuses = {"stealth": 1}

    armor.max_durability = 80
    armor.current_durability = 80
    armor.durability_loss_rate = 1.2
    armor.repair_cost_multiplier = 0.1

    return armor

static func create_leather_boots() -> EquipmentResource:
    """Create leather boots"""
    var boots = EquipmentResource.new()
    boots.item_name = "Leather Boots"
    boots.item_type = EquipmentResource.EquipmentType.ARMOR
    boots.cost = 200  # 2 gold
    boots.weight = 2.0
    boots.description = "Sturdy leather boots for walking."
    boots.rarity = "common"

    boots.armor_type = EquipmentResource.ArmorType.LIGHT
    boots.armor_class = 0
    boots.strength_requirement = 0
    boots.stealth_disadvantage = false

    boots.equipment_slots = ["feet"]
    boots.skill_bonuses = {"stealth": 1}

    boots.max_durability = 60
    boots.current_durability = 60
    boots.durability_loss_rate = 1.5
    boots.repair_cost_multiplier = 0.1

    return boots

static func create_leather_gloves() -> EquipmentResource:
    """Create leather gloves"""
    var gloves = EquipmentResource.new()
    gloves.item_name = "Leather Gloves"
    gloves.item_type = EquipmentResource.EquipmentType.ARMOR
    gloves.cost = 100  # 1 gold
    gloves.weight = 0.5
    gloves.description = "Flexible leather gloves."
    gloves.rarity = "common"

    gloves.armor_type = EquipmentResource.ArmorType.LIGHT
    gloves.armor_class = 0
    gloves.strength_requirement = 0
    gloves.stealth_disadvantage = false

    gloves.equipment_slots = ["hands"]
    gloves.skill_bonuses = {"stealth": 1}

    gloves.max_durability = 50
    gloves.current_durability = 50
    gloves.durability_loss_rate = 1.8
    gloves.repair_cost_multiplier = 0.1

    return gloves

static func create_wizard_robe() -> EquipmentResource:
    """Create wizard's robe"""
    var robe = EquipmentResource.new()
    robe.item_name = "Wizard's Robe"
    robe.item_type = EquipmentResource.EquipmentType.ARMOR
    robe.cost = 1000  # 10 gold
    robe.weight = 2.0
    robe.description = "A flowing robe favored by spellcasters."
    robe.rarity = "common"

    robe.armor_type = EquipmentResource.ArmorType.LIGHT
    robe.armor_class = 10
    robe.strength_requirement = 0
    robe.stealth_disadvantage = false

    robe.equipment_slots = ["chest"]
    robe.ability_bonuses = {"intelligence": 1}
    robe.skill_bonuses = {"arcana": 1}

    robe.max_durability = 70
    robe.current_durability = 70
    robe.durability_loss_rate = 1.0
    robe.repair_cost_multiplier = 0.1

    return robe

static func create_wizard_hat() -> EquipmentResource:
    """Create wizard's hat"""
    var hat = EquipmentResource.new()
    hat.item_name = "Wizard's Hat"
    hat.item_type = EquipmentResource.EquipmentType.ARMOR
    hat.cost = 500  # 5 gold
    hat.weight = 0.5
    hat.description = "A pointed hat that enhances magical abilities."
    hat.rarity = "common"

    hat.armor_type = EquipmentResource.ArmorType.LIGHT
    hat.armor_class = 0
    hat.strength_requirement = 0
    hat.stealth_disadvantage = false

    hat.equipment_slots = ["head"]
    hat.ability_bonuses = {"intelligence": 1}
    hat.skill_bonuses = {"arcana": 1}

    hat.max_durability = 60
    hat.current_durability = 60
    hat.durability_loss_rate = 1.0
    hat.repair_cost_multiplier = 0.1

    return hat

static func create_wizard_staff() -> EquipmentResource:
    """Create wizard's staff"""
    var staff = EquipmentResource.new()
    staff.item_name = "Wizard's Staff"
    staff.item_type = EquipmentResource.EquipmentType.WEAPON
    staff.cost = 2000  # 20 gold
    staff.weight = 4.0
    staff.description = "A wooden staff that serves as both weapon and focus."
    staff.rarity = "common"

    staff.weapon_type = EquipmentResource.WeaponType.MELEE
    staff.damage_dice = "1d6"
    staff.damage_type = "bludgeoning"
    staff.properties = ["versatile"]
    staff.versatile = true
    staff.range_normal = 5
    staff.range_long = 0

    staff.equipment_slots = ["main_hand"]
    staff.ability_bonuses = {"intelligence": 1}
    staff.skill_bonuses = {"arcana": 2}

    staff.max_durability = 90
    staff.current_durability = 90
    staff.durability_loss_rate = 0.8
    staff.repair_cost_multiplier = 0.1

    return staff

static func create_chain_boots() -> EquipmentResource:
    """Create chain boots"""
    var boots = EquipmentResource.new()
    boots.item_name = "Chain Boots"
    boots.item_type = EquipmentResource.EquipmentType.ARMOR
    boots.cost = 1000  # 10 gold
    boots.weight = 8.0
    boots.description = "Heavy boots made of chain links."
    boots.rarity = "common"

    boots.armor_type = EquipmentResource.ArmorType.MEDIUM
    boots.armor_class = 0
    boots.strength_requirement = 13
    boots.stealth_disadvantage = true

    boots.equipment_slots = ["feet"]
    boots.armor_class_bonus = 1

    boots.max_durability = 100
    boots.current_durability = 100
    boots.durability_loss_rate = 0.9
    boots.repair_cost_multiplier = 0.15

    return boots

static func create_chain_gauntlets() -> EquipmentResource:
    """Create chain gauntlets"""
    var gauntlets = EquipmentResource.new()
    gauntlets.item_name = "Chain Gauntlets"
    gauntlets.item_type = EquipmentResource.EquipmentType.ARMOR
    gauntlets.cost = 500  # 5 gold
    gauntlets.weight = 4.0
    gauntlets.description = "Heavy gauntlets made of chain links."
    gauntlets.rarity = "common"

    gauntlets.armor_type = EquipmentResource.ArmorType.MEDIUM
    gauntlets.armor_class = 0
    gauntlets.strength_requirement = 13
    gauntlets.stealth_disadvantage = true

    gauntlets.equipment_slots = ["hands"]
    gauntlets.armor_class_bonus = 1

    gauntlets.max_durability = 100
    gauntlets.current_durability = 100
    gauntlets.durability_loss_rate = 0.9
    gauntlets.repair_cost_multiplier = 0.15

    return gauntlets
