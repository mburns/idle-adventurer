extends Node

# Monster glossary system for managing D&D monsters using Resource system

class_name MonsterGlossary

signal monster_loaded(monster: MonsterResource)
signal glossary_updated()

var monster_manager: MonsterResourceManager
var monsters: Dictionary = {} # monster_name -> MonsterResource
var monster_categories: Dictionary = {} # category -> [monster_names]
var monster_challenge_ratings: Dictionary = {} # cr -> [monster_names]

func _init():
    setup_monster_glossary()

func setup_monster_glossary():
    """Initialize the monster glossary system"""
    print("Monster Glossary initialized")

    # Initialize monster manager
    monster_manager = MonsterResourceManager.new()
    add_child(monster_manager)

    load_all_monsters()

func load_all_monsters():
    """Load all monsters using Resource manager"""
    # Monsters are already loaded by MonsterResourceManager
    monsters = monster_manager.monsters.duplicate()

    # Organize monsters by categories
    for monster_name in monsters.keys():
        var monster_resource = monsters[monster_name]
        categorize_monster_resource(monster_resource)

    print("Loaded ", monsters.size(), " monsters using Resource system")
    glossary_updated.emit()

func categorize_monster_resource(monster_resource: MonsterResource):
    """Categorize a monster resource by type and challenge rating"""
    var monster_name = monster_resource.name

    # Categorize by type
    var monster_type = monster_resource.type.to_lower()
    if not monster_categories.has(monster_type):
        monster_categories[monster_type] = []
    monster_categories[monster_type].append(monster_name)

    # Categorize by challenge rating
    var cr = monster_resource.challenge_rating
    if not monster_challenge_ratings.has(cr):
        monster_challenge_ratings[cr] = []
    monster_challenge_ratings[cr].append(monster_name)

func parse_monster_markdown(content: String, monster_name: String) -> Dictionary:
    """Parse monster data from markdown content"""
    var monster_data = {
        "name": monster_name,
        "type": "unknown",
        "size": "Medium",
        "challenge_rating": 0,
        "hit_points": 0,
        "armor_class": 10,
        "speed": 30,
        "abilities": {},
        "skills": {},
        "senses": [],
        "languages": [],
        "traits": [],
        "actions": [],
        "legendary_actions": [],
        "description": "",
        "source": "wiki"
    }

    var lines = content.split("\n")
    var current_section = ""

    for line in lines:
        line = line.strip_edges()

        if line == "":
            continue

        # Parse headers
        if line.begins_with("# "):
            monster_data["name"] = line.substr(2).strip_edges()
        elif line.begins_with("## "):
            current_section = line.substr(3).strip_edges().to_lower()
        elif line.begins_with("### "):
            current_section = line.substr(4).strip_edges().to_lower()

        # Parse monster stats
        elif current_section == "statistics" or current_section == "stats":
            parse_monster_stats(line, monster_data)

        # Parse abilities
        elif current_section == "abilities":
            parse_monster_abilities(line, monster_data)

        # Parse traits
        elif current_section == "traits":
            parse_monster_traits(line, monster_data)

        # Parse actions
        elif current_section == "actions":
            parse_monster_actions(line, monster_data)

        # Parse legendary actions
        elif current_section == "legendary actions":
            parse_legendary_actions(line, monster_data)

        # Parse description
        elif current_section == "description" or current_section == "overview":
            if monster_data["description"] != "":
                monster_data["description"] += " "
            monster_data["description"] += line

    return monster_data

func parse_monster_stats(line: String, monster_data: Dictionary):
    """Parse monster statistics from a line"""
    if "Challenge Rating" in line or "CR" in line:
        var cr_match = line.get_slice(":", 1).strip_edges()
        monster_data["challenge_rating"] = parse_challenge_rating(cr_match)

    elif "Hit Points" in line or "HP" in line:
        var hp_match = line.get_slice(":", 1).strip_edges()
        monster_data["hit_points"] = parse_hit_points(hp_match)

    elif "Armor Class" in line or "AC" in line:
        var ac_match = line.get_slice(":", 1).strip_edges()
        monster_data["armor_class"] = parse_armor_class(ac_match)

    elif "Speed" in line:
        var speed_match = line.get_slice(":", 1).strip_edges()
        monster_data["speed"] = parse_speed(speed_match)

    elif "Size" in line:
        var size_match = line.get_slice(":", 1).strip_edges()
        monster_data["size"] = size_match

    elif "Type" in line:
        var type_match = line.get_slice(":", 1).strip_edges()
        monster_data["type"] = type_match

func parse_monster_abilities(line: String, monster_data: Dictionary):
    """Parse monster ability scores"""
    var ability_pattern = RegEx.new()
    ability_pattern.compile("(STR|DEX|CON|INT|WIS|CHA)\\s*\\d+")

    var result = ability_pattern.search(line)
    if result:
        var ability = result.get_string(1)
        var value = line.get_slice(ability, 1).strip_edges().get_slice(" ", 0)
        monster_data["abilities"][ability] = value.to_int()

func parse_monster_traits(line: String, monster_data: Dictionary):
    """Parse monster traits"""
    if line.begins_with("**") and line.ends_with("**"):
        var trait_name = line.replace("**", "").strip_edges()
        monster_data["traits"].append({"name": trait_name, "description": ""})
    elif monster_data["traits"].size() > 0:
        var last_trait = monster_data["traits"][-1]
        if last_trait["description"] != "":
            last_trait["description"] += " "
        last_trait["description"] += line

func parse_monster_actions(line: String, monster_data: Dictionary):
    """Parse monster actions"""
    if line.begins_with("**") and line.ends_with("**"):
        var action_name = line.replace("**", "").strip_edges()
        monster_data["actions"].append({"name": action_name, "description": ""})
    elif monster_data["actions"].size() > 0:
        var last_action = monster_data["actions"][-1]
        if last_action["description"] != "":
            last_action["description"] += " "
        last_action["description"] += line

func parse_legendary_actions(line: String, monster_data: Dictionary):
    """Parse legendary actions"""
    if line.begins_with("**") and line.ends_with("**"):
        var action_name = line.replace("**", "").strip_edges()
        monster_data["legendary_actions"].append({"name": action_name, "description": ""})
    elif monster_data["legendary_actions"].size() > 0:
        var last_action = monster_data["legendary_actions"][-1]
        if last_action["description"] != "":
            last_action["description"] += " "
        last_action["description"] += line

func parse_challenge_rating(cr_text: String) -> float:
    """Parse challenge rating from text"""
    cr_text = cr_text.strip_edges()

    if cr_text == "1/8":
        return 0.125
    elif cr_text == "1/4":
        return 0.25
    elif cr_text == "1/2":
        return 0.5
    else:
        return cr_text.to_float()

func parse_hit_points(hp_text: String) -> int:
    """Parse hit points from text"""
    var hp_match = RegEx.new()
    hp_match.compile("(\\d+)")

    var result = hp_match.search(hp_text)
    if result:
        return result.get_string(1).to_int()

    return 0

func parse_armor_class(ac_text: String) -> int:
    """Parse armor class from text"""
    var ac_match = RegEx.new()
    ac_match.compile("(\\d+)")

    var result = ac_match.search(ac_text)
    if result:
        return result.get_string(1).to_int()

    return 10

func parse_speed(speed_text: String) -> int:
    """Parse speed from text"""
    var speed_match = RegEx.new()
    speed_match.compile("(\\d+)")

    var result = speed_match.search(speed_text)
    if result:
        return result.get_string(1).to_int()

    return 30

func categorize_monster(monster_data: Dictionary):
    """Categorize monster by type and challenge rating"""
    var monster_name = monster_data["name"]
    var monster_type = monster_data.get("type", "unknown")
    var cr = monster_data.get("challenge_rating", 0)

    # Categorize by type
    if not monster_categories.has(monster_type):
        monster_categories[monster_type] = []
    monster_categories[monster_type].append(monster_name)

    # Categorize by challenge rating
    var cr_key = str(cr)
    if not monster_challenge_ratings.has(cr_key):
        monster_challenge_ratings[cr_key] = []
    monster_challenge_ratings[cr_key].append(monster_name)

func get_monster(monster_name: String) -> MonsterResource:
    """Get monster resource by name"""
    return monsters.get(monster_name, null)

func get_all_monsters() -> Dictionary:
    """Get all monsters"""
    return monsters

func get_monsters_by_type(monster_type: String) -> Array:
    """Get monsters by type"""
    return monster_categories.get(monster_type, [])

func get_monsters_by_cr(challenge_rating: float) -> Array:
    """Get monsters by challenge rating"""
    var cr_key = str(challenge_rating)
    return monster_challenge_ratings.get(cr_key, [])

func get_monsters_by_cr_range(min_cr: float, max_cr: float) -> Array:
    """Get monsters within challenge rating range"""
    var result = []

    for monster_name in monsters.keys():
        var monster = monsters[monster_name]
        var cr = monster.get("challenge_rating", 0)

        if cr >= min_cr and cr <= max_cr:
            result.append(monster_name)

    return result

func search_monsters(query: String) -> Array:
    """Search monsters by name or description"""
    var results = []
    query = query.to_lower()

    for monster_name in monsters.keys():
        var monster = monsters[monster_name]
        var name = monster.get("name", "").to_lower()
        var description = monster.get("description", "").to_lower()
        var monster_type = monster.get("type", "").to_lower()

        if name.find(query) != -1 or description.find(query) != -1 or monster_type.find(query) != -1:
            results.append(monster_name)

    return results

func get_monster_types() -> Array:
    """Get all monster types"""
    return monster_categories.keys()

func get_challenge_ratings() -> Array:
    """Get all challenge ratings"""
    var crs = monster_challenge_ratings.keys()
    crs.sort_custom(func(a, b): return a.to_float() < b.to_float())
    return crs

func get_monster_count() -> int:
    """Get total number of monsters"""
    return monsters.size()

func get_monster_summary() -> Dictionary:
    """Get summary of monster glossary"""
    var type_counts = {}
    for type_name in monster_categories.keys():
        type_counts[type_name] = monster_categories[type_name].size()

    var cr_counts = {}
    for cr in monster_challenge_ratings.keys():
        cr_counts[cr] = monster_challenge_ratings[cr].size()

    return {
        "total_monsters": monsters.size(),
        "types": type_counts,
        "challenge_ratings": cr_counts
    }

func filter_monsters(filters: Dictionary) -> Array:
    """Filter monsters based on criteria"""
    var results = []

    for monster_name in monsters.keys():
        var monster = monsters[monster_name]
        var matches = true

        # Filter by type
        if filters.has("type") and filters["type"] != "":
            if monster.get("type", "").to_lower() != filters["type"].to_lower():
                matches = false

        # Filter by challenge rating range
        if filters.has("min_cr"):
            if monster.get("challenge_rating", 0) < filters["min_cr"]:
                matches = false

        if filters.has("max_cr"):
            if monster.get("challenge_rating", 0) > filters["max_cr"]:
                matches = false

        # Filter by size
        if filters.has("size") and filters["size"] != "":
            if monster.get("size", "").to_lower() != filters["size"].to_lower():
                matches = false

        # Filter by keyword
        if filters.has("keyword") and filters["keyword"] != "":
            var keyword = filters["keyword"].to_lower()
            var name = monster.get("name", "").to_lower()
            var description = monster.get("description", "").to_lower()

            if name.find(keyword) == -1 and description.find(keyword) == -1:
                matches = false

        if matches:
            results.append(monster_name)

    return results

func get_random_monster(criteria: Dictionary = {}) -> MonsterResource:
    """Get a random monster matching criteria"""
    var filtered = filter_monsters(criteria)

    if filtered.is_empty():
        return null

    var random_index = randi() % filtered.size()
    var monster_name = filtered[random_index]
    return get_monster(monster_name)

func export_monster_data(monster_name: String) -> String:
    """Export monster data as JSON string"""
    var monster = get_monster(monster_name)
    if monster.is_empty():
        return ""

    return JSON.stringify(monster)

func import_monster_data(json_string: String) -> bool:
    """Import monster data from JSON string"""
    var json = JSON.new()
    var parse_result = json.parse(json_string)

    if parse_result != OK:
        return false

    var monster_data = json.get_data()
    if not monster_data is Dictionary:
        return false

    var monster_name = monster_data.get("name", "")
    if monster_name == "":
        return false

    monsters[monster_name] = monster_data
    categorize_monster(monster_data)
    glossary_updated.emit()

    return true
