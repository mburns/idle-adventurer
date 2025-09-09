class_name SpellResource
extends Resource

# D&D Spell as a Godot Resource for better editor integration

@export var spell_name: String = ""
@export var level: int = 0
@export var school: String = "evocation"
@export var casting_time: String = "1 action"
@export var range: String = "60 feet"
@export var components: String = "V, S"
@export var duration: String = "instantaneous"
@export var description: String = ""
@export var higher_levels: String = ""
@export var ritual: bool = false
@export var concentration: bool = false
@export var classes: Array[String] = []

# Spell effects and mechanics
@export var damage_dice: String = "1d6"
@export var damage_type: String = "acid"
@export var saving_throw: String = "Dexterity"
@export var attack_roll: bool = false
@export var area_of_effect: String = ""

# Spell scaling
@export var scales_with_level: bool = true
@export var scaling_dice: String = "1d6"
@export var scaling_levels: Array[int] = [5, 11, 17]

func get_damage_at_level(caster_level: int) -> String:
    if not scales_with_level:
        return damage_dice

    var dice_count = 1
    for level in scaling_levels:
        if caster_level >= level:
            dice_count += 1

    return "%dd%s" % [dice_count, scaling_dice.substr(1)]

func get_range_in_feet() -> int:
    var regex = RegEx.new()
    regex.compile("(\\d+)")
    var result = regex.search(range)
    if result:
        return int(result.get_string(1))
    return 60

func requires_material_component() -> bool:
    return "M" in components

func requires_verbal_component() -> bool:
    return "V" in components

func requires_somatic_component() -> bool:
    return "S" in components

func can_be_cast_as_ritual() -> bool:
    return ritual

func requires_concentration() -> bool:
    return concentration

func get_spell_slot_cost() -> int:
    return level

func is_cantrip() -> bool:
    return level == 0

func get_school_color() -> Color:
    match school.to_lower():
        "abjuration":
            return Color.BLUE
        "conjuration":
            return Color.GREEN
        "divination":
            return Color.YELLOW
        "enchantment":
            return Color.PINK
        "evocation":
            return Color.RED
        "illusion":
            return Color.PURPLE
        "necromancy":
            return Color.BLACK
        "transmutation":
            return Color.ORANGE
        _:
            return Color.WHITE
