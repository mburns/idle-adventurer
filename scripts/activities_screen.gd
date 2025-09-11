extends Control

# Dynamic activities screen that generates UI from data/activities/*.json files
# No more hardcoded tabs or repeated definitions!

var character: Character
var enhanced_activities: EnhancedActivities
var activity_containers: Dictionary = {}
var progress_bars: Dictionary = {} # activity_id -> progress_bar
var tab_container: TabContainer
var ability_icons: Dictionary = {
    "strength": "💪",
    "dexterity": "🏃", 
    "intelligence": "🧠",
    "wisdom": "👁️",
    "charisma": "🗣️",
    "constitution": "💪",
    "general": "🌍"
}

func _ready():
    # Apply theme
    ThemeManager.apply_theme_to_node(self)

    # Get current character
    character = CharacterManager.current_character

    # Initialize enhanced activities system
    enhanced_activities = EnhancedActivities.new()
    add_child(enhanced_activities)

    # Connect to activity signals
    enhanced_activities.activity_started.connect(_on_activity_started)
    enhanced_activities.activity_completed.connect(_on_activity_completed)
    enhanced_activities.activity_progress.connect(_on_activity_progress)

    # Get reference to tab container
    tab_container = %TabContainer

    # Dynamically generate tabs and containers from JSON data
    generate_dynamic_tabs()

    # Display all activities
    display_all_activities()

    # Setup progress bar update timer
    var progress_timer = Timer.new()
    progress_timer.wait_time = 1.0 # Update every second
    progress_timer.timeout.connect(_update_progress_bars)
    progress_timer.autostart = true
    add_child(progress_timer)

func generate_dynamic_tabs():
    """Dynamically generate tabs and containers from JSON data"""
    # Clear existing tabs
    for child in tab_container.get_children():
        child.queue_free()
    
    # Get all activities data
    var all_activities = enhanced_activities.get_all_activities()
    
    # Create tabs for each ability that has activities
    for ability in all_activities.keys():
        var activities = all_activities[ability]
        if activities.size() > 0:  # Only create tab if there are activities
            create_tab_for_ability(ability, activities)

func create_tab_for_ability(ability: String, activities: Dictionary):
    """Create a tab and container for a specific ability"""
    # Create the tab control
    var tab_control = Control.new()
    tab_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    
    # Create scroll container
    var scroll_container = ScrollContainer.new()
    scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    tab_control.add_child(scroll_container)
    
    # Create activities container
    var activities_container = VBoxContainer.new()
    activities_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll_container.add_child(activities_container)
    
    # Add tab to container
    var tab_title = ability_icons.get(ability, "📋") + " " + ability.capitalize()
    tab_container.add_child(tab_control)
    tab_container.set_tab_title(tab_container.get_tab_count() - 1, tab_title)
    
    # Store reference to activities container
    activity_containers[ability] = activities_container

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

    # Clear existing activities and progress bars
    for child in container.get_children():
        child.queue_free()

    # Clear progress bars for this ability's activities
    for activity_id in activities.keys():
        if progress_bars.has(activity_id):
            progress_bars.erase(activity_id)

    # Add activities
    for activity_id in activities.keys():
        var activity = activities[activity_id]
        var activity_panel = create_activity_panel(ability, activity_id, activity)
        container.add_child(activity_panel)

func create_activity_panel(ability: String, activity_id: String, activity: Dictionary) -> Panel:
    """Create a dynamic panel for an activity based on JSON data"""
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
    name_label.text = activity.get("name", "Unknown Activity")
    name_label.add_theme_font_size_override("font_size", 16)
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(name_label)

    # Requirements display (dynamically generated from JSON)
    var requirements_label = Label.new()
    var requirements_text = get_requirements_text(activity.get("requirements", {}))
    requirements_label.text = requirements_text
    requirements_label.add_theme_font_size_override("font_size", 12)
    requirements_label.add_theme_color_override("font_color", Color.GRAY)
    header.add_child(requirements_label)

    container.add_child(header)

    # Description (from JSON)
    var desc_label = Label.new()
    desc_label.text = activity.get("description", "No description available")
    desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc_label.add_theme_font_size_override("font_size", 12)
    container.add_child(desc_label)

    # Progress and rewards info (dynamically generated from JSON)
    var info_container = HBoxContainer.new()

    # Daily progress (from JSON)
    var daily_progress_label = Label.new()
    var progress_percent = int(activity.get("daily_progress", 0.0) * 100)
    daily_progress_label.text = "Progress: " + str(progress_percent) + "%/day"
    daily_progress_label.add_theme_font_size_override("font_size", 11)
    daily_progress_label.add_theme_color_override("font_color", Color.CYAN)
    info_container.add_child(daily_progress_label)

    # Cost info (from JSON)
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

    # Dynamic rewards display (from JSON)
    var rewards_container = create_rewards_display(activity.get("rewards", {}))
    if rewards_container:
        container.add_child(rewards_container)

    # Action buttons with progress bar
    var button_container = VBoxContainer.new()

    # Check if character can start this activity
    var can_start = false
    var is_active = false

    if character != null:
        can_start = enhanced_activities.can_start_activity(character, activity_id, ability)
        is_active = is_activity_active(activity_id)

    # Add progress bar for active activities
    if is_active:
        var progress_bar_container = HBoxContainer.new()

        var progress_label = Label.new()
        progress_label.text = "Progress:"
        progress_label.add_theme_font_size_override("font_size", 12)
        progress_bar_container.add_child(progress_label)

        var progress_bar = ProgressBar.new()
        progress_bar.custom_minimum_size = Vector2(200, 20)
        progress_bar.max_value = 1.0
        progress_bar.value = get_activity_progress(activity_id)
        progress_bar.show_percentage = true
        progress_bar_container.add_child(progress_bar)

        # Store progress bar reference for updates
        progress_bars[activity_id] = progress_bar

        button_container.add_child(progress_bar_container)

        var action_buttons = HBoxContainer.new()
        var stop_button = Button.new()
        stop_button.text = "Stop Activity"
        stop_button.add_theme_color_override("font_color", Color.RED)
        stop_button.pressed.connect(func(): stop_activity(activity_id))
        action_buttons.add_child(stop_button)

        var progress_button = Button.new()
        progress_button.text = "View Details"
        progress_button.pressed.connect(func(): show_activity_progress(activity_id))
        action_buttons.add_child(progress_button)

        button_container.add_child(action_buttons)
    elif can_start:
        var start_button = Button.new()
        start_button.text = "Start Activity"
        start_button.add_theme_color_override("font_color", Color.GREEN)
        start_button.pressed.connect(func(): start_activity(ability, activity_id))
        button_container.add_child(start_button)
    else:
        var cant_start_label = Label.new()
        if character == null:
            cant_start_label.text = "No character selected"
        else:
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

func get_activity_progress(activity_id: String) -> float:
    """Get the current progress of an activity"""
    var active_activities = enhanced_activities.get_active_activities()
    for activity in active_activities.values():
        if activity.get("id") == activity_id:
            return activity.get("progress", 0.0)
    return 0.0

func clear_all_progress_bars():
    """Clear all progress bars"""
    for activity_id in progress_bars.keys():
        var progress_bar = progress_bars[activity_id]
        if progress_bar and is_instance_valid(progress_bar):
            progress_bar.value = 0.0

func start_activity(ability: String, activity_id: String):
    """Start an activity"""
    # Clear all progress bars when starting a new activity
    clear_all_progress_bars()

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

    # Don't clear progress bar - activity will restart automatically
    # The progress bar will reset to 0 and start filling again

    # Show completion dialog
    show_activity_completion(activity_name, rewards)
    # Refresh display
    display_all_activities()

func _on_activity_progress(activity_name: String, character: Character, progress: float):
    """Handle activity progress signal"""
    # Update progress bars in real-time
    _update_progress_bars()

func _update_progress_bars():
    """Update all progress bars with current activity progress"""
    for activity_id in progress_bars.keys():
        var progress_bar = progress_bars[activity_id]
        if progress_bar and is_instance_valid(progress_bar):
            var current_progress = get_activity_progress(activity_id)
            progress_bar.value = current_progress

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
