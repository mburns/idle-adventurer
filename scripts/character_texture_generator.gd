class_name CharacterTextureGenerator
extends RefCounted

# Preload required classes
const Character = preload("res://scripts/character.gd")

# Generates character textures based on stats and equipment

static func generate_character_texture(character: Character) -> ImageTexture:
    var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)

    # Generate base character
    generate_base_character(image, character)

    # Add equipment layers
    generate_equipment_layers(image, character)

    # Apply stat-based modifications
    apply_stat_modifications(image, character)

    # Convert to texture
    var texture = ImageTexture.new()
    texture.set_image(image)
    return texture

static func generate_base_character(image: Image, character: Character):
    # Generate base character silhouette based on race and class
    var race_color = get_race_color(character.race)
    var class_accent = get_class_accent_color(character.character_class)

    # Draw character body
    draw_character_body(image, race_color, class_accent)

    # Draw character head
    draw_character_head(image, race_color, character)

static func draw_character_body(image: Image, base_color: Color, accent_color: Color):
    # Draw a simple character body
    var center_x = image.get_width() / 2
    var center_y = image.get_height() / 2

    # Body (torso)
    draw_ellipse(image, center_x, center_y + 10, 12, 16, base_color)

    # Head
    draw_circle(image, center_x, center_y - 8, 8, base_color)

    # Arms
    draw_ellipse(image, center_x - 12, center_y, 4, 12, base_color)
    draw_ellipse(image, center_x + 12, center_y, 4, 12, base_color)

    # Legs
    draw_ellipse(image, center_x - 4, center_y + 20, 4, 12, base_color)
    draw_ellipse(image, center_x + 4, center_y + 20, 4, 12, base_color)

static func draw_character_head(image: Image, base_color: Color, character: Character):
    var center_x = image.get_width() / 2
    var center_y = image.get_height() / 2

    # Head shape based on race
    match character.race.to_lower():
        "human":
            draw_circle(image, center_x, center_y - 8, 8, base_color)
        "elf":
            draw_ellipse(image, center_x, center_y - 8, 6, 10, base_color)
        "dwarf":
            draw_ellipse(image, center_x, center_y - 6, 8, 6, base_color)
        "halfling":
            draw_circle(image, center_x, center_y - 6, 6, base_color)
        _:
            draw_circle(image, center_x, center_y - 8, 8, base_color)

    # Add facial features based on stats
    draw_facial_features(image, center_x, center_y - 8, character)

static func draw_facial_features(image: Image, x: int, y: int, character: Character):
    # Eyes
    var eye_color = Color.WHITE
    if character.intelligence >= 14:
        eye_color = Color.CYAN
    elif character.wisdom >= 14:
        eye_color = Color.YELLOW

    image.set_pixel(x - 2, y - 2, eye_color)
    image.set_pixel(x + 2, y - 2, eye_color)

    # Expression based on charisma
    if character.get_charisma_modifier() >= 2:
        # Smile
        draw_arc(image, x, y + 1, 3, 0, PI, 3, Color.BLACK)
    elif character.get_charisma_modifier() <= -2:
        # Frown
        draw_arc(image, x, y + 3, 3, PI, 2 * PI, 3, Color.BLACK)

static func generate_equipment_layers(image: Image, character: Character):
    # Add equipment on top of base character
    for slot in character.equipment.keys():
        var item_name = character.equipment[slot]
        draw_equipment_item(image, slot, item_name)

static func draw_equipment_item(image: Image, slot: String, item_name: String):
    var item_color = get_item_color(item_name)

    match slot:
        "head":
            draw_helmet(image, item_color)
        "chest":
            draw_armor(image, item_color)
        "main_hand":
            draw_weapon(image, item_color, true)
        "off_hand":
            draw_weapon(image, item_color, false)
        "legs":
            draw_leg_armor(image, item_color)
        "feet":
            draw_boots(image, item_color)

static func draw_helmet(image: Image, color: Color):
    var center_x = image.get_width() / 2
    var center_y = image.get_height() / 2

    # Simple helmet shape
    draw_ellipse(image, center_x, center_y - 8, 10, 8, color)

static func draw_armor(image: Image, color: Color):
    var center_x = image.get_width() / 2
    var center_y = image.get_height() / 2

    # Armor overlay on torso
    draw_ellipse(image, center_x, center_y + 10, 14, 18, color)

static func draw_weapon(image: Image, color: Color, is_main_hand: bool):
    var center_x = image.get_width() / 2
    var center_y = image.get_height() / 2

    var weapon_x = center_x + (12 if is_main_hand else -12)

    # Simple weapon (sword)
    draw_line(image, weapon_x, center_y - 5, weapon_x, center_y + 15, color, 2)

static func draw_leg_armor(image: Image, color: Color):
    var center_x = image.get_width() / 2
    var center_y = image.get_height() / 2

    # Leg armor
    draw_ellipse(image, center_x - 4, center_y + 20, 6, 14, color)
    draw_ellipse(image, center_x + 4, center_y + 20, 6, 14, color)

static func draw_boots(image: Image, color: Color):
    var center_x = image.get_width() / 2
    var center_y = image.get_height() / 2

    # Boots
    draw_ellipse(image, center_x - 4, center_y + 28, 5, 4, color)
    draw_ellipse(image, center_x + 4, center_y + 28, 5, 4, color)

static func apply_stat_modifications(image: Image, character: Character):
    # Apply visual modifications based on character stats

    # Size based on Constitution
    var con_modifier = character.get_constitution_modifier()
    if con_modifier > 0:
        # Make character appear stronger
        apply_strength_effect(image, con_modifier)

    # Dexterity affects posture
    var dex_modifier = character.get_dexterity_modifier()
    if dex_modifier > 0:
        apply_agility_effect(image, dex_modifier)

    # Intelligence affects aura
    var int_modifier = character.get_intelligence_modifier()
    if int_modifier > 0:
        apply_intelligence_effect(image, int_modifier)

static func apply_strength_effect(image: Image, modifier: int):
    # Make character appear more muscular
    var strength_color = Color(1.0, 0.8, 0.6)  # Slightly more defined
    # This would add muscle definition to the character

static func apply_agility_effect(image: Image, modifier: int):
    # Make character appear more lithe
    var agility_color = Color(0.9, 0.9, 1.0)  # Slightly more graceful
    # This would make the character appear more agile

static func apply_intelligence_effect(image: Image, modifier: int):
    # Add a subtle glow or aura
    var int_color = Color(0.8, 0.8, 1.0)  # Slight blue tint
    # This would add a subtle magical aura

# Helper drawing functions
static func draw_circle(image: Image, center_x: int, center_y: int, radius: int, color: Color):
    for x in range(center_x - radius, center_x + radius + 1):
        for y in range(center_y - radius, center_y + radius + 1):
            var distance = sqrt((x - center_x) * (x - center_x) + (y - center_y) * (y - center_y))
            if distance <= radius:
                image.set_pixel(x, y, color)

static func draw_ellipse(image: Image, center_x: int, center_y: int, width: int, height: int, color: Color):
    for x in range(center_x - width, center_x + width + 1):
        for y in range(center_y - height, center_y + height + 1):
            var normalized_x = float(x - center_x) / width
            var normalized_y = float(y - center_y) / height
            if normalized_x * normalized_x + normalized_y * normalized_y <= 1.0:
                image.set_pixel(x, y, color)

static func draw_line(image: Image, x1: int, y1: int, x2: int, y2: int, color: Color, thickness: int = 1):
    # Simple line drawing algorithm
    var dx = abs(x2 - x1)
    var dy = abs(y2 - y1)
    var sx = 1 if x1 < x2 else -1
    var sy = 1 if y1 < y2 else -1
    var err = dx - dy

    var x = x1
    var y = y1

    while true:
        # Draw pixel with thickness
        for i in range(-thickness/2, thickness/2 + 1):
            for j in range(-thickness/2, thickness/2 + 1):
                if x + i >= 0 and x + i < image.get_width() and y + j >= 0 and y + j < image.get_height():
                    image.set_pixel(x + i, y + j, color)

        if x == x2 and y == y2:
            break

        var e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x += sx
        if e2 < dx:
            err += dx
            y += sy

static func draw_arc(image: Image, center_x: int, center_y: int, radius: int, start_angle: float, end_angle: float, thickness: int, color: Color):
    # Simple arc drawing
    var angle_step = 0.1
    var current_angle = start_angle

    while current_angle <= end_angle:
        var x = center_x + radius * cos(current_angle)
        var y = center_y + radius * sin(current_angle)

        # Draw pixel with thickness
        for i in range(-thickness/2, thickness/2 + 1):
            for j in range(-thickness/2, thickness/2 + 1):
                if x + i >= 0 and x + i < image.get_width() and y + j >= 0 and y + j < image.get_height():
                    image.set_pixel(int(x + i), int(y + j), color)

        current_angle += angle_step

# Color generation functions
static func get_race_color(race: String) -> Color:
    match race.to_lower():
        "human":
            return Color(0.8, 0.6, 0.4)  # Tan
        "elf":
            return Color(0.9, 0.8, 0.7)  # Pale
        "dwarf":
            return Color(0.6, 0.4, 0.3)  # Brown
        "halfling":
            return Color(0.7, 0.5, 0.3)  # Light brown
        "dragonborn":
            return Color(0.8, 0.4, 0.2)  # Orange
        "gnome":
            return Color(0.7, 0.6, 0.5)  # Light tan
        "half_elf":
            return Color(0.8, 0.7, 0.5)  # Mixed
        "half_orc":
            return Color(0.4, 0.3, 0.2)  # Dark
        "tiefling":
            return Color(0.6, 0.3, 0.6)  # Purple
        _:
            return Color(0.8, 0.6, 0.4)  # Default tan

static func get_class_accent_color(class_type: String) -> Color:
    match class_type.to_lower():
        "barbarian":
            return Color(0.8, 0.2, 0.2)  # Red
        "bard":
            return Color(0.8, 0.2, 0.8)  # Purple
        "cleric":
            return Color(1.0, 1.0, 0.2)  # Yellow
        "druid":
            return Color(0.2, 0.8, 0.2)  # Green
        "fighter":
            return Color(0.5, 0.5, 0.5)  # Gray
        "monk":
            return Color(0.8, 0.6, 0.2)  # Orange
        "paladin":
            return Color(0.2, 0.2, 0.8)  # Blue
        "ranger":
            return Color(0.2, 0.6, 0.2)  # Dark Green
        "rogue":
            return Color(0.3, 0.3, 0.3)  # Dark Gray
        "sorcerer":
            return Color(0.8, 0.4, 0.8)  # Magenta
        "warlock":
            return Color(0.4, 0.2, 0.8)  # Dark Purple
        "wizard":
            return Color(0.2, 0.4, 0.8)  # Light Blue
        _:
            return Color.WHITE

static func get_item_color(item_name: String) -> Color:
    # Determine item color based on name
    if "leather" in item_name.to_lower():
        return Color(0.6, 0.4, 0.2)  # Brown
    elif "chain" in item_name.to_lower():
        return Color(0.7, 0.7, 0.7)  # Silver
    elif "plate" in item_name.to_lower():
        return Color(0.8, 0.8, 0.8)  # Bright silver
    elif "magic" in item_name.to_lower():
        return Color(0.8, 0.2, 0.8)  # Purple
    elif "sword" in item_name.to_lower():
        return Color(0.9, 0.9, 0.9)  # Steel
    elif "bow" in item_name.to_lower():
        return Color(0.6, 0.4, 0.2)  # Wood
    else:
        return Color(0.5, 0.5, 0.5)  # Default gray
