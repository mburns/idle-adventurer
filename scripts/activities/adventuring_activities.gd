extends Node

# Adventuring activities system based on D&D wiki content

class_name AdventuringActivities

signal activity_started(activity: String, character: Character)
signal activity_completed(activity: String, character: Character, rewards: Dictionary)
signal activity_progress(activity: String, character: Character, progress: float)

# Activity types
enum ActivityType {
    CRAFTING,
    PROFESSION,
    TRAINING,
    RESEARCH,
    SOCIALIZING
}

# Lifestyle expenses
enum Lifestyle {
    WRETCHED = 0,      # Free
    SQUAID = 1,        # 1 sp/day
    POOR = 2,          # 2 sp/day
    MODEST = 3,        # 1 gp/day
    COMFORTABLE = 4,   # 2 gp/day
    WEALTHY = 5,       # 4 gp/day
    ARISTOCRATIC = 6   # 10+ gp/day
}

var lifestyle_data: Dictionary = {}  # lifestyle_id -> lifestyle_data
var lifestyle_costs: Dictionary = {}  # Lifestyle enum -> daily_cost

var active_activities: Dictionary = {}  # character_id -> activity_data
var character_lifestyles: Dictionary = {}  # character_id -> lifestyle

func _init():
    setup_activity_system()

func setup_activity_system():
    """Initialize the adventuring activities system"""
    load_lifestyle_data()

    # Set up activity timers
    var timer = Timer.new()
    timer.wait_time = 1.0  # Check every second
    timer.timeout.connect(_process_activities)
    timer.autostart = true
    add_child(timer)

func start_crafting(character: Character, item_name: String, materials_cost: float, market_value: float):
    """Start crafting an item"""
    var activity_data = {
        "type": ActivityType.CRAFTING,
        "item_name": item_name,
        "materials_cost": materials_cost,
        "market_value": market_value,
        "progress": 0.0,
        "daily_progress": 5.0,  # 5 gp per day
        "start_time": Time.get_unix_time_from_system(),
        "total_days_needed": int(ceil(market_value / 5.0))
    }

    active_activities[character.name] = activity_data
    activity_started.emit("Crafting " + item_name, character)

    print("Started crafting " + item_name + " (Value: " + str(market_value) + " gp)")

func start_profession(character: Character, profession: String):
    """Start practicing a profession"""
    var lifestyle = character_lifestyles.get(character.name, Lifestyle.MODEST)
    var daily_income = get_profession_income(profession, lifestyle)

    var activity_data = {
        "type": ActivityType.PROFESSION,
        "profession": profession,
        "daily_income": daily_income,
        "start_time": Time.get_unix_time_from_system(),
        "last_payment": Time.get_unix_time_from_system()
    }

    active_activities[character.name] = activity_data
    activity_started.emit("Practicing " + profession, character)

    print("Started practicing " + profession + " (Income: " + str(daily_income) + " gp/day)")

func start_training(character: Character, skill: String, cost_per_day: float = 1.0):
    """Start training a skill or language"""
    var training_days = 250  # Standard D&D training time
    var total_cost = training_days * cost_per_day

    var activity_data = {
        "type": ActivityType.TRAINING,
        "skill": skill,
        "cost_per_day": cost_per_day,
        "total_cost": total_cost,
        "days_remaining": training_days,
        "start_time": Time.get_unix_time_from_system(),
        "last_payment": Time.get_unix_time_from_system()
    }

    active_activities[character.name] = activity_data
    activity_started.emit("Training " + skill, character)

    print("Started training " + skill + " (Cost: " + str(cost_per_day) + " gp/day for " + str(training_days) + " days)")

func get_profession_income(profession: String, lifestyle: Lifestyle) -> float:
    """Calculate daily income from profession"""
    var base_income = 0.0

    match profession.to_lower():
        "performance":
            base_income = 4.0  # Wealthy lifestyle
        "temple_work", "guild_work":
            base_income = 2.0  # Comfortable lifestyle
        "general_labor":
            base_income = 1.0  # Modest lifestyle
        _:
            base_income = 1.0  # Default to modest

    # Apply lifestyle modifier from loaded data
    var lifestyle_name = get_lifestyle_name(lifestyle)
    var lifestyle_info = lifestyle_data.get(lifestyle_name, {})
    var profession_modifiers = lifestyle_info.get("profession_modifiers", {})
    var modifier = profession_modifiers.get(profession.to_lower(), 1.0)

    # Adjust based on character's faction benefits
    # This would be implemented based on faction system

    return base_income * modifier

func _process_activities():
    """Process all active activities"""
    var current_time = Time.get_unix_time_from_system()

    for character_name in active_activities.keys():
        var activity = active_activities[character_name]
        var character = get_character_by_name(character_name)

        if not character:
            continue

        match activity.type:
            ActivityType.CRAFTING:
                process_crafting(character, activity, current_time)
            ActivityType.PROFESSION:
                process_profession(character, activity, current_time)
            ActivityType.TRAINING:
                process_training(character, activity, current_time)

func process_crafting(character: Character, activity: Dictionary, current_time: float):
    """Process crafting activity"""
    var days_elapsed = (current_time - activity.start_time) / 86400.0  # Convert to days
    var progress = min(days_elapsed * activity.daily_progress, activity.market_value)

    activity.progress = progress
    activity_progress.emit("Crafting " + activity.item_name, character, progress / activity.market_value)

    if progress >= activity.market_value:
        complete_crafting(character, activity)

func process_profession(character: Character, activity: Dictionary, current_time: float):
    """Process profession activity"""
    var days_elapsed = (current_time - activity.last_payment) / 86400.0

    if days_elapsed >= 1.0:  # Pay daily
        var income = activity.daily_income
        character.gold += income
        activity.last_payment = current_time

        var rewards = {"gold": income}
        activity_completed.emit("Daily " + activity.profession + " income", character, rewards)

        print(character.name + " earned " + str(income) + " gp from " + activity.profession)

func process_training(character: Character, activity: Dictionary, current_time: float):
    """Process training activity"""
    var days_elapsed = (current_time - activity.last_payment) / 86400.0

    if days_elapsed >= 1.0:  # Pay daily
        var daily_cost = activity.cost_per_day

        if character.gold >= daily_cost:
            character.gold -= daily_cost
            activity.days_remaining -= 1
            activity.last_payment = current_time

            print(character.name + " paid " + str(daily_cost) + " gp for " + activity.skill + " training (" + str(activity.days_remaining) + " days remaining)")

            if activity.days_remaining <= 0:
                complete_training(character, activity)
        else:
            # Can't afford training
            stop_activity(character.name, "Insufficient funds for training")

func complete_crafting(character: Character, activity: Dictionary):
    """Complete crafting activity"""
    var item_name = activity.item_name
    var market_value = activity.market_value
    var materials_cost = activity.materials_cost

    # Create the crafted item
    var crafted_item = create_crafted_item(item_name, market_value)

    # Add to character's inventory (this would be implemented with inventory system)
    # character.add_item(crafted_item)

    var rewards = {
        "item": crafted_item,
        "gold_saved": market_value - materials_cost
    }

    activity_completed.emit("Crafted " + item_name, character, rewards)
    stop_activity(character.name, "Crafting completed")

    print(character.name + " completed crafting " + item_name + " (Value: " + str(market_value) + " gp)")

func complete_training(character: Character, activity: Dictionary):
    """Complete training activity"""
    var skill = activity.skill

    # Add skill proficiency (this would be implemented with skill system)
    # character.add_skill_proficiency(skill)

    var rewards = {
        "skill": skill,
        "proficiency": true
    }

    activity_completed.emit("Learned " + skill, character, rewards)
    stop_activity(character.name, "Training completed")

    print(character.name + " completed training in " + skill)

func create_crafted_item(item_name: String, market_value: float) -> Dictionary:
    """Create a crafted item"""
    return {
        "name": item_name,
        "type": "crafted",
        "market_value": market_value,
        "crafted_by": "player"
    }

func stop_activity(character_name: String, reason: String = ""):
    """Stop an activity for a character"""
    if character_name in active_activities:
        active_activities.erase(character_name)
        print("Stopped activity for " + character_name + " (" + reason + ")")

func set_character_lifestyle(character: Character, lifestyle: Lifestyle):
    """Set a character's lifestyle"""
    character_lifestyles[character.name] = lifestyle
    print(character.name + " lifestyle set to " + get_lifestyle_name(lifestyle))

func get_lifestyle_name(lifestyle: Lifestyle) -> String:
    """Get lifestyle name"""
    match lifestyle:
        Lifestyle.WRETCHED:
            return "Wretched"
        Lifestyle.SQUAID:
            return "Squalid"
        Lifestyle.POOR:
            return "Poor"
        Lifestyle.MODEST:
            return "Modest"
        Lifestyle.COMFORTABLE:
            return "Comfortable"
        Lifestyle.WEALTHY:
            return "Wealthy"
        Lifestyle.ARISTOCRATIC:
            return "Aristocratic"
        _:
            return "Unknown"

func get_daily_lifestyle_cost(character: Character) -> float:
    """Get daily lifestyle cost for character"""
    var lifestyle = character_lifestyles.get(character.name, Lifestyle.MODEST)
    return lifestyle_costs.get(lifestyle, 1.0)  # Default to modest cost if not found

func get_character_by_name(name: String) -> Character:
    """Get character by name (placeholder - would use CharacterManager)"""
    # This would be implemented with proper character management
    return null

func get_active_activities() -> Dictionary:
    """Get all active activities"""
    return active_activities.duplicate()

func get_character_activity(character_name: String) -> Dictionary:
    """Get activity for specific character"""
    return active_activities.get(character_name, {})

# YAML loading functions for lifestyles
func load_lifestyle_data() -> void:
    """Load lifestyle data from YAML file"""
    var file_path = "res://data/lifestyles.yaml"
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        print("Error: Could not open lifestyles file: " + file_path)
        return

    var yaml_string = file.get_as_text()
    file.close()

    # Use the resource manager instead of custom parsing
    var lifestyle_manager = AutoloadManager.get_lifestyle_manager()
    if lifestyle_manager == null:
        print("Error: Lifestyle manager not available")
        return

    var all_lifestyles = lifestyle_manager.get_all_lifestyles()
    for lifestyle_id in all_lifestyles:
        var lifestyle_resource = all_lifestyles[lifestyle_id]

        # Convert resource to legacy format
        var lifestyle_info = {
            "id": lifestyle_resource.id,
            "name": lifestyle_resource.name,
            "daily_cost": lifestyle_resource.daily_cost,
            "description": lifestyle_resource.description
        }
        var id = lifestyle_info.get("id", "")
        var name = lifestyle_info.get("name", "")
        var daily_cost = lifestyle_info.get("daily_cost", 0.0)
        var description = lifestyle_info.get("description", "")
        var benefits = lifestyle_info.get("benefits", [])
        var profession_modifiers = lifestyle_info.get("profession_modifiers", {})

        # Store lifestyle data
        lifestyle_data[id] = {
            "name": name,
            "daily_cost": daily_cost,
            "description": description,
            "benefits": benefits,
            "profession_modifiers": profession_modifiers
        }

        # Convert string ID to enum and store cost
        var lifestyle_enum = string_to_lifestyle_enum(id)
        lifestyle_costs[lifestyle_enum] = daily_cost

    print("Loaded " + str(lifestyle_data.size()) + " lifestyle definitions")

# Custom YAML parsing function removed - now using unified YAMLParser via resource manager

func parse_yaml_lifestyles_removed(yaml_string: String) -> Array:
    """Parse YAML lifestyles array format"""
    var lines = yaml_string.split("\n")
    var lifestyles = []
    var current_lifestyle = {}
    var current_key = ""
    var in_multiline = false
    var indent_level = 0

    for line in lines:
        line = line.strip_edges()
        if line.is_empty() or line.begins_with("#"):
            continue

        var line_indent = get_indent_level(line)

        # Handle array items (lifestyles)
        if line.begins_with("- ") and line_indent == 0:
            # Save previous lifestyle if exists
            if not current_lifestyle.is_empty():
                lifestyles.append(current_lifestyle)

            # Start new lifestyle
            current_lifestyle = {}
            var item_line = line.substr(2).strip_edges()
            if ":" in item_line:
                var parts = item_line.split(":", 1)
                current_key = parts[0].strip_edges()
                var value = parts[1].strip_edges()
                if value.is_empty():
                    in_multiline = true
                else:
                    current_lifestyle[current_key] = parse_value(value)
            indent_level = 0
        elif line.begins_with("-") and line_indent > 0:
            # Handle nested array items (benefits)
            var item = line.substr(1).strip_edges()
            if not current_lifestyle.has(current_key):
                current_lifestyle[current_key] = []
            current_lifestyle[current_key].append(parse_value(item))
        elif ":" in line and line_indent > 0:
            # Handle key-value pairs within lifestyle
            if in_multiline and current_key != "":
                current_lifestyle[current_key] = current_lifestyle.get(current_key, "").strip_edges()
                in_multiline = false

            var parts = line.split(":", 1)
            current_key = parts[0].strip_edges()
            var value = parts[1].strip_edges()

            if value.is_empty():
                in_multiline = true
                current_lifestyle[current_key] = ""
            else:
                current_lifestyle[current_key] = parse_value(value)
        elif in_multiline and line_indent > indent_level:
            # Continue multiline value
            current_lifestyle[current_key] += "\n" + line
        elif line_indent == 0 and not line.begins_with("-"):
            # Handle top-level key-value pairs
            if in_multiline and current_key != "":
                current_lifestyle[current_key] = current_lifestyle.get(current_key, "").strip_edges()
                in_multiline = false

            var parts = line.split(":", 1)
            current_key = parts[0].strip_edges()
            var value = parts[1].strip_edges()

            if value.is_empty():
                in_multiline = true
                current_lifestyle[current_key] = ""
            else:
                current_lifestyle[current_key] = parse_value(value)

    # Save last lifestyle
    if not current_lifestyle.is_empty():
        lifestyles.append(current_lifestyle)

    return lifestyles

func get_indent_level(line: String) -> int:
    """Get the indentation level of a line"""
    var indent = 0
    for i in range(line.length()):
        if line[i] == " ":
            indent += 1
        elif line[i] == "\t":
            indent += 4
        else:
            break
    return indent

func parse_value(value: String) -> Variant:
    """Parse a YAML value string into appropriate type"""
    # Try to parse as number
    if value.is_valid_int():
        return value.to_int()
    elif value.is_valid_float():
        return value.to_float()
    # Try to parse as boolean
    elif value == "true":
        return true
    elif value == "false":
        return false
    # Try to parse as null/empty
    elif value == "null" or value == "~" or value == "":
        return null
    # Return as string
    else:
        return value

# Enum conversion function
func string_to_lifestyle_enum(lifestyle_str: String) -> Lifestyle:
    """Convert string to Lifestyle enum"""
    match lifestyle_str:
        "WRETCHED":
            return Lifestyle.WRETCHED
        "SQUAID":
            return Lifestyle.SQUAID
        "POOR":
            return Lifestyle.POOR
        "MODEST":
            return Lifestyle.MODEST
        "COMFORTABLE":
            return Lifestyle.COMFORTABLE
        "WEALTHY":
            return Lifestyle.WEALTHY
        "ARISTOCRATIC":
            return Lifestyle.ARISTOCRATIC
        _:
            print("Warning: Unknown lifestyle: " + lifestyle_str)
            return Lifestyle.MODEST
