extends Control

# Activities screen showing all available activities organized by ability score

var character: Character
var enhanced_activities: EnhancedActivities
var activity_containers: Dictionary = {}

func _ready():
    # Apply theme
    ThemeManager.apply_theme_to_children(self)

    # Get current character
    character = CharacterManager.current_character

    # Initialize enhanced activities system
    enhanced_activities = EnhancedActivities.new()
    add_child(enhanced_activities)

    # Connect to activity signals
    enhanced_activities.activity_started.connect(_on_activity_started)
    enhanced_activities.activity_completed.connect(_on_activity_completed)
    enhanced_activities.activity_progress.connect(_on_activity_progress)

    # Setup activity containers
    setup_activity_containers()

    # Display all activities
    display_all_activities()

func setup_activity_containers():
    """Setup references to activity containers for each ability"""
    var tab_container = %TabContainer

    for i in range(tab_container.get_tab_count()):
        var tab = tab_container.get_tab_control(i)
        var scroll_container = tab.get_child(0) # First child should be ScrollContainer
        var activities_container = scroll_container.get_child(0) # First child should be VBoxContainer

        var ability_name = tab_container.get_tab_title(i).split(" ")[-1].to_lower()
        if ability_name == "💪":
            ability_name = "strength" if i == 0 else "constitution"
        elif ability_name == "🏃":
            ability_name = "dexterity"
        elif ability_name == "🧠":
            ability_name = "intelligence"
        elif ability_name == "👁️":
            ability_name = "wisdom"
        elif ability_name == "🗣️":
            ability_name = "charisma"
        elif ability_name == "🌍":
            ability_name = "general"

        activity_containers[ability_name] = activities_container

func display_all_activities():
    """Display all activities organized by ability"""
    var all_activities = enhanced_activities.get_all_activities()

    for ability in all_activities.keys():
        display_activities_for_ability(ability, all_activities[ability])

func display_activities_for_ability(ability: String, activities: Dictionary):
    """Display activities for a specific ability"""
    var container = activity_containers.get(ability)
    if not container:
        return

    # Clear existing activities
    for child in container.get_children():
        child.queue_free()

    # Add activities
    for activity_id in activities.keys():
        var activity = activities[activity_id]
        var activity_panel = create_activity_panel(ability, activity_id, activity)
        container.add_child(activity_panel)

func create_activity_panel(ability: String, activity_id: String, activity: Dictionary) -> Panel:
    """Create a panel for an activity"""
    var panel = Panel.new()
    panel.custom_minimum_size = Vector2(0, 120)

    var container = VBoxContainer.new()
    container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    container.offset_left = 10
    container.offset_top = 10
    container.offset_right = -10
    container.offset_bottom = -10

    # Header with activity name and requirements
    var header = HBoxContainer.new()

    var name_label = Label.new()
    name_label.text = activity["name"]
    name_label.add_theme_font_size_override("font_size", 16)
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(name_label)

    # Requirements display
    var requirements_label = Label.new()
    var requirements_text = get_requirements_text(activity.get("requirements", {}))
    requirements_label.text = requirements_text
    requirements_label.add_theme_font_size_override("font_size", 12)
    requirements_label.add_theme_color_override("font_color", Color.GRAY)
    header.add_child(requirements_label)

    container.add_child(header)

    # Description
    var desc_label = Label.new()
    desc_label.text = activity["description"]
    desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc_label.add_theme_font_size_override("font_size", 12)
    container.add_child(desc_label)

    # Progress and rewards info
    var info_container = HBoxContainer.new()

    # Daily progress
    var progress_label = Label.new()
    var progress_percent = int(activity["daily_progress"] * 100)
    progress_label.text = "Progress: " + str(progress_percent) + "%/day"
    progress_label.add_theme_font_size_override("font_size", 11)
    progress_label.add_theme_color_override("font_color", Color.CYAN)
    info_container.add_child(progress_label)

    # Cost info
    var cost_label = Label.new()
    var cost = activity.get("cost_per_day", 0.0)
    if cost > 0:
        cost_label.text = "Cost: " + str(cost) + " gp/day"
        cost_label.add_theme_color_override("font_color", Color.RED)
    else:
        cost_label.text = "Earns money"
        cost_label.add_theme_color_override("font_color", Color.GREEN)
    cost_label.add_theme_font_size_override("font_size", 11)
    info_container.add_child(cost_label)

    container.add_child(info_container)

    # Action buttons
    var button_container = HBoxContainer.new()

    # Check if character can start this activity
    var can_start = enhanced_activities.can_start_activity(character, activity_id, ability)
    var is_active = is_activity_active(activity_id)

    if is_active:
        var stop_button = Button.new()
        stop_button.text = "Stop Activity"
        stop_button.add_theme_color_override("font_color", Color.RED)
        stop_button.pressed.connect(func(): stop_activity(activity_id))
        button_container.add_child(stop_button)

        var progress_button = Button.new()
        progress_button.text = "View Progress"
        progress_button.pressed.connect(func(): show_activity_progress(activity_id))
        button_container.add_child(progress_button)
    elif can_start:
        var start_button = Button.new()
        start_button.text = "Start Activity"
        start_button.add_theme_color_override("font_color", Color.GREEN)
        start_button.pressed.connect(func(): start_activity(ability, activity_id))
        button_container.add_child(start_button)
    else:
        var cant_start_label = Label.new()
        cant_start_label.text = "Requirements not met"
        cant_start_label.add_theme_color_override("font_color", Color.GRAY)
        button_container.add_child(cant_start_label)

    container.add_child(button_container)

    panel.add_child(container)
    return panel

func get_requirements_text(requirements: Dictionary) -> String:
    """Get formatted requirements text"""
    var req_text = ""

    for req_type in requirements.keys():
        var value = requirements[req_type]

        match req_type:
            "strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma":
                req_text += req_type.capitalize() + ": " + str(value) + " "
            "gold":
                req_text += "Gold: " + str(value) + "gp "
            "tools":
                req_text += "Tools: " + str(value) + " "
            "faction_member":
                if value:
                    req_text += "Faction Member "

    return req_text.strip_edges()

func is_activity_active(activity_id: String) -> bool:
    """Check if an activity is currently active"""
    var active_activities = enhanced_activities.get_active_activities()
    for activity in active_activities.values():
        if activity.get("id") == activity_id:
            return true
    return false

func start_activity(ability: String, activity_id: String):
    """Start an activity"""
    if enhanced_activities.start_activity(character, activity_id, ability):
        # Refresh display
        display_all_activities()

func stop_activity(activity_id: String):
    """Stop an activity"""
    enhanced_activities.stop_activity(character.name, "Stopped by player")
    # Refresh display
    display_all_activities()

func show_activity_progress(activity_id: String):
    """Show detailed progress for an activity"""
    var active_activities = enhanced_activities.get_active_activities()
    var activity = null

    for active_activity in active_activities.values():
        if active_activity.get("id") == activity_id:
            activity = active_activity
            break

    if not activity:
        return

    var dialog = AcceptDialog.new()
    dialog.title = activity["name"] + " Progress"

    var content = VBoxContainer.new()

    # Progress bar
    var progress_label = Label.new()
    var progress_percent = int(activity["progress"] * 100)
    progress_label.text = "Progress: " + str(progress_percent) + "%"
    content.add_child(progress_label)

    # Time info
    var time_label = Label.new()
    var start_time = activity.get("start_time", 0)
    var current_time = Time.get_unix_time_from_system()
    var days_elapsed = (current_time - start_time) / 86400.0
    time_label.text = "Days elapsed: " + str(int(days_elapsed))
    content.add_child(time_label)

    # Rewards info
    var rewards_label = Label.new()
    var rewards = activity.get("rewards", {})
    var rewards_text = "Rewards: "
    for reward_type in rewards.keys():
        rewards_text += reward_type + " (" + str(rewards[reward_type]) + ") "
    rewards_label.text = rewards_text
    rewards_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_child(rewards_label)

    dialog.add_child(content)
    add_child(dialog)
    dialog.popup_centered()

func _on_activity_started(activity_name: String, character: Character, ability: String):
    """Handle activity started signal"""
    print("Activity started: " + activity_name + " for " + character.name)
    # Refresh display
    display_all_activities()

func _on_activity_completed(activity_name: String, character: Character, rewards: Dictionary):
    """Handle activity completed signal"""
    print("Activity completed: " + activity_name + " for " + character.name)
    # Show completion dialog
    show_activity_completion(activity_name, rewards)
    # Refresh display
    display_all_activities()

func _on_activity_progress(activity_name: String, character: Character, progress: float):
    """Handle activity progress signal"""
    # Could update UI in real-time here
    pass

func show_activity_completion(activity_name: String, rewards: Dictionary):
    """Show activity completion dialog"""
    var dialog = AcceptDialog.new()
    dialog.title = "Activity Completed!"

    var content = VBoxContainer.new()

    var title_label = Label.new()
    title_label.text = "Completed: " + activity_name
    title_label.add_theme_font_size_override("font_size", 16)
    content.add_child(title_label)

    var rewards_label = Label.new()
    var rewards_text = "Rewards received:\n"
    for reward_type in rewards.keys():
        rewards_text += "• " + reward_type.capitalize() + ": " + str(rewards[reward_type]) + "\n"
    rewards_label.text = rewards_text
    content.add_child(rewards_label)

    dialog.add_child(content)
    add_child(dialog)
    dialog.popup_centered()

func _on_back_button_pressed():
    """Return to main screen"""
    get_tree().change_scene_to_file("res://scenes/main.tscn")
