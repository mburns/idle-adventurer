extends Node

# Asset pipeline for managing character sprites and other game assets

# Character sprite categories
enum SpriteCategory {
    BODY,
    HEAD,
    HAIR,
    FACIAL_HAIR,
    EYES,
    CLOTHING,
    ARMOR,
    WEAPONS,
    ACCESSORIES
}

# Sprite data structure
class SpriteData:
    var id: String
    var category: SpriteCategory
    var path: String
    var variants: Array[String] = []
    var requirements: Dictionary = {} # e.g., {"race": "Human", "class": "Fighter"}

    func _init(sprite_id: String, sprite_category: SpriteCategory, sprite_path: String):
        id = sprite_id
        category = sprite_category
        path = sprite_path

# Available character sprites
var character_sprites: Array[SpriteData] = []

func _ready():
    initialize_character_sprites()

func initialize_character_sprites():
    # Body sprites
    character_sprites.append(SpriteData.new("human_body", SpriteCategory.BODY,
            "res://assets/character_sprites/human_body.png"))
    character_sprites.append(SpriteData.new("elf_body", SpriteCategory.BODY,
            "res://assets/character_sprites/elf_body.png"))
    character_sprites.append(SpriteData.new("dwarf_body", SpriteCategory.BODY,
            "res://assets/character_sprites/dwarf_body.png"))

    # Head sprites
    character_sprites.append(SpriteData.new("human_head", SpriteCategory.HEAD,
            "res://assets/character_sprites/human_head.png"))
    character_sprites.append(SpriteData.new("elf_head", SpriteCategory.HEAD,
            "res://assets/character_sprites/elf_head.png"))
    character_sprites.append(SpriteData.new("dwarf_head", SpriteCategory.HEAD,
            "res://assets/character_sprites/dwarf_head.png"))

    # Hair sprites
    character_sprites.append(SpriteData.new("short_hair", SpriteCategory.HAIR,
            "res://assets/character_sprites/short_hair.png"))
    character_sprites.append(SpriteData.new("long_hair", SpriteCategory.HAIR,
            "res://assets/character_sprites/long_hair.png"))
    character_sprites.append(SpriteData.new("bald", SpriteCategory.HAIR,
            "res://assets/character_sprites/bald.png"))

    # Clothing sprites
    character_sprites.append(SpriteData.new("common_clothes", SpriteCategory.CLOTHING,
            "res://assets/character_sprites/common_clothes.png"))
    character_sprites.append(SpriteData.new("noble_clothes", SpriteCategory.CLOTHING,
            "res://assets/character_sprites/noble_clothes.png"))
    character_sprites.append(SpriteData.new("traveler_clothes", SpriteCategory.CLOTHING,
            "res://assets/character_sprites/traveler_clothes.png"))

    # Armor sprites
    character_sprites.append(SpriteData.new("leather_armor", SpriteCategory.ARMOR,
            "res://assets/character_sprites/leather_armor.png"))
    character_sprites.append(SpriteData.new("chain_mail", SpriteCategory.ARMOR,
            "res://assets/character_sprites/chain_mail.png"))
    character_sprites.append(SpriteData.new("plate_armor", SpriteCategory.ARMOR,
            "res://assets/character_sprites/plate_armor.png"))

    # Weapon sprites
    character_sprites.append(SpriteData.new("sword", SpriteCategory.WEAPONS,
            "res://assets/character_sprites/sword.png"))
    character_sprites.append(SpriteData.new("bow", SpriteCategory.WEAPONS,
            "res://assets/character_sprites/bow.png"))
    character_sprites.append(SpriteData.new("staff", SpriteCategory.WEAPONS,
            "res://assets/character_sprites/staff.png"))

# Get sprites by category
func get_sprites_by_category(category: SpriteCategory) -> Array[SpriteData]:
    var result: Array[SpriteData] = []
    for sprite in character_sprites:
        if sprite.category == category:
            result.append(sprite)
    return result

# Get sprites that match character requirements
func get_sprites_for_character(character: Character) -> Dictionary:
    var result: Dictionary = {}

    for category in SpriteCategory.values():
        var category_sprites = get_sprites_by_category(category)
        var matching_sprites: Array[SpriteData] = []

        for sprite in category_sprites:
            if sprite_matches_character(sprite, character):
                matching_sprites.append(sprite)

        result[category] = matching_sprites

    return result

# Check if a sprite matches character requirements
func sprite_matches_character(sprite: SpriteData, character: Character) -> bool:
    var requirements = sprite.requirements

    # Check race requirement
    if requirements.has("race") and requirements["race"] != character.race:
        return false

    # Check class requirement
    if requirements.has("class") and requirements["class"] != character.character_class:
        return false

    # Check level requirement
    if requirements.has("min_level") and character.level < requirements["min_level"]:
        return false

    return true

# Generate character sprite composition
func generate_character_sprite(character: Character) -> Dictionary:
    var sprite_layers: Dictionary = {}
    var available_sprites = get_sprites_for_character(character)

    # Select sprites for each category
    for category in SpriteCategory.values():
        var category_sprites = available_sprites.get(category, [])
        if category_sprites.size() > 0:
            # For now, just pick the first available sprite
            # In a real implementation, this could be more sophisticated
            sprite_layers[category] = category_sprites[0]

    return sprite_layers

# Create placeholder sprites for development
func create_placeholder_sprites():
    print("Creating placeholder character sprites...")

    # This would create simple colored rectangles as placeholders
    # In a real implementation, you'd have actual sprite files

    for sprite in character_sprites:
        print("Placeholder for: " + sprite.id + " at " + sprite.path)

# Validate sprite files exist
func validate_sprite_files() -> Array[String]:
    var missing_files: Array[String] = []

    for sprite in character_sprites:
        if not FileAccess.file_exists(sprite.path):
            missing_files.append(sprite.path)

    return missing_files

# Get sprite statistics
func get_sprite_statistics() -> Dictionary:
    var stats = {
        "total_sprites": character_sprites.size(),
        "by_category": {}
    }

    for category in SpriteCategory.values():
        stats["by_category"][SpriteCategory.keys()[category]] = get_sprites_by_category(category).size()

    return stats
