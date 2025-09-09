class_name CharacterClassResource
extends Resource

# D&D Class as a Godot Resource for better editor integration

@export var class_name: String = ""
@export var hit_die: int = 8
@export var primary_ability: String = "strength"
@export var saving_throws: Array[String] = []
@export var skill_choices: int = 2
@export var skill_options: Array[String] = []
@export var armor_proficiencies: Array[String] = []
@export var weapon_proficiencies: Array[String] = []
@export var tool_proficiencies: Array[String] = []
@export var starting_equipment: Dictionary = {}
@export var features: Array[String] = []
@export var spellcasting_ability: String = ""
@export var spell_slots_per_level: Array[int] = []

# Level progression table
@export var level_features: Array[Dictionary] = []

func get_hit_points_at_level(level: int, constitution_modifier: int) -> int:
    var base_hp = hit_die + constitution_modifier
    var additional_hp = (level - 1) * (hit_die / 2 + 1 + constitution_modifier)
    return base_hp + additional_hp

func get_proficiency_bonus_at_level(level: int) -> int:
    return 2 + floor((level - 1) / 4.0)

func get_spell_slots_at_level(level: int) -> Array[int]:
    if level > spell_slots_per_level.size():
        return []
    return spell_slots_per_level[level - 1]

func get_features_at_level(level: int) -> Array[String]:
    var features_at_level = []
    for level_data in level_features:
        if level_data.has("level") and level_data.level == level:
            if level_data.has("features"):
                features_at_level.append_array(level_data.features)
    return features_at_level
