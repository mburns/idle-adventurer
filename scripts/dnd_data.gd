class_name DnDData
extends Resource

# D&D 5e Races
static var races = {
    "Human": {
        "ability_increases": {
            "strength": 1, "dexterity": 1, "constitution": 1,
            "intelligence": 1, "wisdom": 1, "charisma": 1
        },
        "size": "Medium",
        "speed": 30,
        "languages": ["Common"],
        "traits": ["Extra Language", "Extra Skill"]
    },
    "Elf": {
        "ability_increases": {"dexterity": 2},
        "size": "Medium",
        "speed": 30,
        "languages": ["Common", "Elvish"],
        "traits": ["Darkvision", "Fey Ancestry", "Trance", "Keen Senses"]
    },
    "Dwarf": {
        "ability_increases": {"constitution": 2},
        "size": "Medium",
        "speed": 25,
        "languages": ["Common", "Dwarvish"],
        "traits": ["Darkvision", "Dwarven Resilience", "Dwarven Combat Training", "Stonecunning"]
    },
    "Halfling": {
        "ability_increases": {"dexterity": 2},
        "size": "Small",
        "speed": 25,
        "languages": ["Common", "Halfling"],
        "traits": ["Lucky", "Brave", "Halfling Nimbleness"]
    },
    "Dragonborn": {
        "ability_increases": {"strength": 2, "charisma": 1},
        "size": "Medium",
        "speed": 30,
        "languages": ["Common", "Draconic"],
        "traits": ["Draconic Ancestry", "Breath Weapon", "Damage Resistance"]
    },
    "Gnome": {
        "ability_increases": {"intelligence": 2},
        "size": "Small",
        "speed": 25,
        "languages": ["Common", "Gnomish"],
        "traits": ["Darkvision", "Gnome Cunning"]
    },
    "Half-Elf": {
        "ability_increases": {"charisma": 2},
        "size": "Medium",
        "speed": 30,
        "languages": ["Common", "Elvish"],
        "traits": ["Darkvision", "Fey Ancestry", "Two Skill Proficiencies"]
    },
    "Half-Orc": {
        "ability_increases": {"strength": 2, "constitution": 1},
        "size": "Medium",
        "speed": 30,
        "languages": ["Common", "Orc"],
        "traits": ["Darkvision", "Relentless Endurance", "Savage Attacks"]
    },
    "Tiefling": {
        "ability_increases": {"intelligence": 1, "charisma": 2},
        "size": "Medium",
        "speed": 30,
        "languages": ["Common", "Infernal"],
        "traits": ["Darkvision", "Hellish Resistance", "Infernal Legacy"]
    }
}

# D&D 5e Classes
static var classes = {
    "Barbarian": {
        "hit_die": 12,
        "primary_ability": "strength",
        "saving_throws": ["strength", "constitution"],
        "skill_choices": 2,
        "skill_options": ["Animal Handling", "Athletics", "Intimidation", "Nature", "Perception", "Survival"],
        "armor_proficiencies": ["Light Armor", "Medium Armor", "Shields"],
        "weapon_proficiencies": ["Simple Weapons", "Martial Weapons"],
        "tool_proficiencies": [],
        "starting_equipment": {
            "weapons": ["Greataxe", "Two Handaxes"],
            "armor": [],
            "other": ["Explorer's Pack", "Four Javelins"]
        }
    },
    "Bard": {
        "hit_die": 8,
        "primary_ability": "charisma",
        "saving_throws": ["dexterity", "charisma"],
        "skill_choices": 3,
        "skill_options": [
            "Animal Handling", "Athletics", "Deception", "History", "Insight",
            "Intimidation", "Investigation", "Medicine", "Nature", "Perception",
            "Performance", "Persuasion", "Religion", "Sleight of Hand", "Stealth"
        ],
        "armor_proficiencies": ["Light Armor"],
        "weapon_proficiencies": ["Simple Weapons", "Hand Crossbows", "Longswords", "Rapiers", "Shortswords"],
        "tool_proficiencies": ["Three Musical Instruments"],
        "starting_equipment": {
            "weapons": ["Rapier", "Longsword", "Dagger"],
            "armor": ["Leather Armor"],
            "other": ["Diplomat's Pack", "Entertainer's Pack", "Lute", "Leather Armor"]
        }
    },
    "Cleric": {
        "hit_die": 8,
        "primary_ability": "wisdom",
        "saving_throws": ["wisdom", "charisma"],
        "skill_choices": 2,
        "skill_options": ["History", "Insight", "Medicine", "Persuasion", "Religion"],
        "armor_proficiencies": ["Light Armor", "Medium Armor", "Shields"],
        "weapon_proficiencies": ["Simple Weapons"],
        "tool_proficiencies": [],
        "starting_equipment": {
            "weapons": ["Mace", "Warhammer"],
            "armor": ["Scale Mail", "Leather Armor"],
            "other": ["Priest's Pack", "Explorer's Pack", "Shield", "Holy Symbol"]
        }
    },
    "Druid": {
        "hit_die": 8,
        "primary_ability": "wisdom",
        "saving_throws": ["intelligence", "wisdom"],
        "skill_choices": 2,
        "skill_options": ["Arcana", "Animal Handling", "Insight", "Medicine", "Nature", "Perception", "Religion", "Survival"],
        "armor_proficiencies": ["Light Armor", "Medium Armor", "Shields"],
        "weapon_proficiencies": ["Clubs", "Daggers", "Darts", "Javelins", "Maces", "Quarterstaffs", "Scimitars", "Sickles", "Slings", "Spears"],
        "tool_proficiencies": ["Herbalism Kit"],
        "starting_equipment": {
            "weapons": ["Scimitar", "Quarterstaff"],
            "armor": ["Leather Armor", "Hide Armor"],
            "other": ["Explorer's Pack", "Druid's Pack", "Shield", "Druidic Focus"]
        }
    },
    "Fighter": {
        "hit_die": 10,
        "primary_ability": "strength",
        "saving_throws": ["strength", "constitution"],
        "skill_choices": 2,
        "skill_options": ["Acrobatics", "Animal Handling", "Athletics", "History", "Insight", "Intimidation", "Perception", "Survival"],
        "armor_proficiencies": ["All Armor", "Shields"],
        "weapon_proficiencies": ["Simple Weapons", "Martial Weapons"],
        "tool_proficiencies": [],
        "starting_equipment": {
            "weapons": ["Chain Mail", "Leather Armor", "Longbow", "Shield"],
            "armor": ["Chain Mail", "Leather Armor"],
            "other": ["Dungeoneer's Pack", "Explorer's Pack", "Shield", "Dungeoneer's Pack"]
        }
    },
    "Monk": {
        "hit_die": 8,
        "primary_ability": "dexterity",
        "saving_throws": ["strength", "dexterity"],
        "skill_choices": 2,
        "skill_options": ["Acrobatics", "Athletics", "History", "Insight", "Religion", "Stealth"],
        "armor_proficiencies": [],
        "weapon_proficiencies": ["Simple Weapons", "Shortswords"],
        "tool_proficiencies": ["One Type of Artisan's Tools", "One Musical Instrument"],
        "starting_equipment": {
            "weapons": ["Shortsword", "Dart"],
            "armor": [],
            "other": ["Dungeoneer's Pack", "Explorer's Pack", "Dart"]
        }
    },
    "Paladin": {
        "hit_die": 10,
        "primary_ability": "strength",
        "saving_throws": ["wisdom", "charisma"],
        "skill_choices": 2,
        "skill_options": ["Athletics", "Insight", "Intimidation", "Medicine", "Persuasion", "Religion"],
        "armor_proficiencies": ["All Armor", "Shields"],
        "weapon_proficiencies": ["Simple Weapons", "Martial Weapons"],
        "tool_proficiencies": [],
        "starting_equipment": {
            "weapons": ["Martial Weapon", "Shield", "Javelin"],
            "armor": ["Chain Mail", "Leather Armor"],
            "other": ["Priest's Pack", "Explorer's Pack", "Shield", "Holy Symbol"]
        }
    },
    "Ranger": {
        "hit_die": 10,
        "primary_ability": "dexterity",
        "saving_throws": ["strength", "dexterity"],
        "skill_choices": 3,
        "skill_options": ["Animal Handling", "Athletics", "Insight", "Investigation", "Nature", "Perception", "Stealth", "Survival"],
        "armor_proficiencies": ["Light Armor", "Medium Armor", "Shields"],
        "weapon_proficiencies": ["Simple Weapons", "Martial Weapons"],
        "tool_proficiencies": [],
        "starting_equipment": {
            "weapons": ["Scale Mail", "Leather Armor", "Longbow"],
            "armor": ["Scale Mail", "Leather Armor"],
            "other": ["Explorer's Pack", "Dungeoneer's Pack", "Longbow"]
        }
    },
    "Rogue": {
        "hit_die": 8,
        "primary_ability": "dexterity",
        "saving_throws": ["dexterity", "intelligence"],
        "skill_choices": 4,
        "skill_options": ["Acrobatics", "Athletics", "Deception", "Insight", "Intimidation", "Investigation", "Perception", "Performance", "Persuasion", "Sleight of Hand", "Stealth"],
        "armor_proficiencies": ["Light Armor"],
        "weapon_proficiencies": ["Simple Weapons", "Hand Crossbows", "Longswords", "Rapiers", "Shortswords"],
        "tool_proficiencies": ["Thieves' Tools"],
        "starting_equipment": {
            "weapons": ["Rapier", "Shortsword", "Shortbow"],
            "armor": ["Leather Armor"],
            "other": ["Burglar's Pack", "Dungeoneer's Pack", "Leather Armor", "Thieves' Tools"]
        }
    },
    "Sorcerer": {
        "hit_die": 6,
        "primary_ability": "charisma",
        "saving_throws": ["constitution", "charisma"],
        "skill_choices": 2,
        "skill_options": ["Arcana", "Deception", "Insight", "Intimidation", "Persuasion", "Religion"],
        "armor_proficiencies": [],
        "weapon_proficiencies": ["Daggers", "Darts", "Slings", "Quarterstaffs", "Light Crossbows"],
        "tool_proficiencies": [],
        "starting_equipment": {
            "weapons": ["Dagger", "Dart", "Sling"],
            "armor": [],
            "other": ["Dungeoneer's Pack", "Explorer's Pack", "Dagger"]
        }
    },
    "Warlock": {
        "hit_die": 8,
        "primary_ability": "charisma",
        "saving_throws": ["wisdom", "charisma"],
        "skill_choices": 2,
        "skill_options": ["Arcana", "Deception", "History", "Intimidation", "Investigation", "Nature", "Religion"],
        "armor_proficiencies": ["Light Armor"],
        "weapon_proficiencies": ["Simple Weapons"],
        "tool_proficiencies": [],
        "starting_equipment": {
            "weapons": ["Light Crossbow", "Dagger", "Dart"],
            "armor": ["Leather Armor"],
            "other": ["Scholar's Pack", "Dungeoneer's Pack", "Leather Armor", "Dagger"]
        }
    },
    "Wizard": {
        "hit_die": 6,
        "primary_ability": "intelligence",
        "saving_throws": ["intelligence", "wisdom"],
        "skill_choices": 2,
        "skill_options": ["Arcana", "History", "Insight", "Investigation", "Medicine", "Religion"],
        "armor_proficiencies": [],
        "weapon_proficiencies": ["Daggers", "Darts", "Slings", "Quarterstaffs", "Light Crossbows"],
        "tool_proficiencies": [],
        "starting_equipment": {
            "weapons": ["Dagger", "Dart", "Sling"],
            "armor": [],
            "other": ["Scholar's Pack", "Explorer's Pack", "Dagger"]
        }
    }
}

# D&D 5e Backgrounds
static var backgrounds = {
    "Acolyte": {
        "skill_proficiencies": ["Insight", "Religion"],
        "languages": ["Two of your choice"],
        "equipment": ["Holy Symbol", "Prayer Book", "Incense", "Common Clothes", "Belt Pouch", "15 GP"],
        "feature": "Shelter of the Faithful"
    },
    "Criminal": {
        "skill_proficiencies": ["Deception", "Stealth"],
        "tool_proficiencies": ["One Type of Gaming Set", "Thieves' Tools"],
        "languages": [],
        "equipment": ["Crowbar", "Dark Common Clothes", "Belt Pouch", "15 GP"],
        "feature": "Criminal Contact"
    },
    "Folk Hero": {
        "skill_proficiencies": ["Animal Handling", "Survival"],
        "tool_proficiencies": ["One Type of Artisan's Tools", "Vehicles (Land)"],
        "languages": [],
        "equipment": ["Artisan's Tools", "Shovel", "Iron Pot", "Common Clothes", "Belt Pouch", "10 GP"],
        "feature": "Rustic Hospitality"
    },
    "Noble": {
        "skill_proficiencies": ["History", "Persuasion"],
        "tool_proficiencies": ["One Type of Gaming Set"],
        "languages": ["One of your choice"],
        "equipment": ["Signet Ring", "Scroll of Pedigree", "Purse", "25 GP"],
        "feature": "Position of Privilege"
    },
    "Sage": {
        "skill_proficiencies": ["Arcana", "History"],
        "languages": ["Two of your choice"],
        "equipment": ["Ink", "Quill", "Small Knife", "Letter from a Dead Colleague", "Common Clothes", "Belt Pouch", "10 GP"],
        "feature": "Researcher"
    },
    "Soldier": {
        "skill_proficiencies": ["Athletics", "Intimidation"],
        "tool_proficiencies": ["One Type of Gaming Set", "Vehicles (Land)"],
        "languages": [],
        "equipment": ["Insignia of Rank", "Trophy", "Playing Cards", "Common Clothes", "Belt Pouch", "10 GP"],
        "feature": "Military Rank"
    }
}

# D&D 5e Skills
static var skills = {
    "Acrobatics": {"ability": "dexterity", "description": "Keep your balance while walking on narrow or unstable surfaces"},
    "Animal Handling": {"ability": "wisdom", "description": "Calm down a domesticated animal, intuit an animal's intentions, or control your mount"},
    "Arcana": {"ability": "intelligence", "description": "Recall lore about spells, magic items, eldritch symbols, magical traditions, or planes of existence"},
    "Athletics": {"ability": "strength", "description": "Attempt to climb, jump, or swim"},
    "Deception": {"ability": "charisma", "description": "Lie convincingly or hide the truth"},
    "History": {"ability": "intelligence", "description": "Recall lore about historical events, legendary people, ancient kingdoms, past disputes, recent wars, or lost civilizations"},
    "Insight": {"ability": "wisdom", "description": "Determine the true intentions of a creature"},
    "Intimidation": {"ability": "charisma", "description": "Influence someone through threats, hostile actions, and physical violence"},
    "Investigation": {"ability": "intelligence", "description": "Look for clues and make deductions based on those clues"},
    "Medicine": {"ability": "wisdom", "description": "Stabilize a dying companion or diagnose an illness"},
    "Nature": {"ability": "intelligence", "description": "Recall lore about terrain, plants and animals, the weather, or natural cycles"},
    "Perception": {"ability": "wisdom", "description": "Spot, hear, or otherwise detect the presence of something"},
    "Performance": {"ability": "charisma", "description": "Delight an audience with music, dance, acting, storytelling, or some other form of entertainment"},
    "Persuasion": {"ability": "charisma", "description": "Influence someone through tact, social graces, or good nature"},
    "Religion": {"ability": "intelligence", "description": "Recall lore about deities, rites and prayers, religious hierarchies, holy symbols, or practices of secret cults"},
    "Sleight of Hand": {"ability": "dexterity", "description": "Pick a pocket, plant something on someone, or lift a coin purse"},
    "Stealth": {"ability": "dexterity", "description": "Conceal yourself from enemies, slink past guards, slip away without being noticed, or sneak up on someone"},
    "Survival": {"ability": "wisdom", "description": "Follow tracks, hunt wild game, guide your group through frozen wastelands, identify signs that owlbears live nearby, predict the weather, or avoid quicksand and other natural hazards"}
}

# Get race data
static func get_race(race_name: String) -> Dictionary:
    return races.get(race_name, {})

# Get class data
static func get_class_data(class_type: String) -> Dictionary:
    return classes.get(class_type, {})

# Get background data
static func get_background(background_name: String) -> Dictionary:
    return backgrounds.get(background_name, {})

# Get skill data
static func get_skill(skill_name: String) -> Dictionary:
    return skills.get(skill_name, {})

# Get all race names
static func get_race_names() -> Array[String]:
    return races.keys()

# Get all class names
static func get_class_names() -> Array[String]:
    return classes.keys()

# Get all background names
static func get_background_names() -> Array[String]:
    return backgrounds.keys()

# Get all skill names
static func get_skill_names() -> Array[String]:
    return skills.keys()
