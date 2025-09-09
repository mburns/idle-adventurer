extends Control

# Character Journal screen for roleplay notes and campaign tracking

var character: Character
var journal_data: Dictionary = {
    "background_story": "",
    "campaign_entries": [],
    "timeline_events": []
}

func _ready():
    # Apply theme
    ThemeManager.apply_theme_to_children(self)

    # Get current character
    character = CharacterManager.current_character

    # Load journal data
    load_journal_data()

    # Display current data
    update_display()

func load_journal_data():
    """Load journal data for current character"""
    if not character:
        return

    var file_path = "user://journals/" + character.name + "_journal.dat"
    var file = FileAccess.open(file_path, FileAccess.READ)

    if file:
        var json_string = file.get_as_text()
        file.close()

        var json = JSON.new()
        var parse_result = json.parse(json_string)
        if parse_result == OK:
            var data = json.get_data()
            if data is Dictionary:
                journal_data = data

func save_journal_data():
    """Save journal data for current character"""
    if not character:
        return

    # Update background story from text field
    journal_data.background_story = %BackgroundText.text

    # Ensure directories exist
    var dir = DirAccess.open("user://")
    if not dir.dir_exists("journals"):
        dir.make_dir("journals")

    var file_path = "user://journals/" + character.name + "_journal.dat"
    var file = FileAccess.open(file_path, FileAccess.WRITE)

    if file:
        file.store_string(JSON.stringify(journal_data))
        file.close()
        print("Journal saved for " + character.name)

func update_display():
    """Update the display with current journal data"""
    # Update background text
    %BackgroundText.text = journal_data.get("background_story", "")

    # Update campaign entries
    update_campaign_entries()

    # Update timeline events
    update_timeline_events()

func update_campaign_entries():
    """Update the campaign entries display"""
    var container = %CampaignContainer

    # Clear existing entries
    for child in container.get_children():
        child.queue_free()

    var entries = journal_data.get("campaign_entries", [])

    if entries.is_empty():
        var no_entries_label = Label.new()
        no_entries_label.text = "No campaign entries yet. Add your first campaign session notes!"
        no_entries_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        no_entries_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        container.add_child(no_entries_label)
        return

    # Display entries (newest first)
    entries.reverse()
    for entry in entries:
        var entry_panel = create_campaign_entry_panel(entry)
        container.add_child(entry_panel)

func update_timeline_events():
    """Update the timeline events display"""
    var container = %TimelineContainer

    # Clear existing events
    for child in container.get_children():
        child.queue_free()

    var events = journal_data.get("timeline_events", [])

    if events.is_empty():
        var no_events_label = Label.new()
        no_events_label.text = "No timeline events yet. Document important moments in your character's life!"
        no_events_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        no_events_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        container.add_child(no_events_label)
        return

    # Sort events by date (newest first)
    events.sort_custom(func(a, b): return a.get("timestamp", 0) > b.get("timestamp", 0))

    for event in events:
        var event_panel = create_timeline_event_panel(event)
        container.add_child(event_panel)

func create_campaign_entry_panel(entry: Dictionary) -> Panel:
    """Create a panel for a campaign entry"""
    var panel = Panel.new()
    panel.custom_minimum_size = Vector2(0, 120)

    var container = VBoxContainer.new()
    container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    container.offset_left = 10
    container.offset_top = 10
    container.offset_right = -10
    container.offset_bottom = -10

    # Header with date and session info
    var header = HBoxContainer.new()

    var title_label = Label.new()
    title_label.text = entry.get("title", "Campaign Session")
    title_label.add_theme_font_size_override("font_size", 16)
    title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title_label)

    var date_label = Label.new()
    var timestamp = entry.get("timestamp", 0)
    if timestamp > 0:
        var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
        date_label.text = "%04d-%02d-%02d" % [datetime.year, datetime.month, datetime.day]
    else:
        date_label.text = "Unknown Date"
    date_label.add_theme_font_size_override("font_size", 12)
    date_label.add_theme_color_override("font_color", Color.GRAY)
    header.add_child(date_label)

    # Delete button
    var delete_button = Button.new()
    delete_button.text = "×"
    delete_button.custom_minimum_size = Vector2(30, 30)
    delete_button.pressed.connect(func(): delete_campaign_entry(entry))
    header.add_child(delete_button)

    container.add_child(header)

    # Content
    var content_label = Label.new()
    content_label.text = entry.get("content", "")
    content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    container.add_child(content_label)

    panel.add_child(container)
    return panel

func create_timeline_event_panel(event: Dictionary) -> Panel:
    """Create a panel for a timeline event"""
    var panel = Panel.new()
    panel.custom_minimum_size = Vector2(0, 80)

    var container = VBoxContainer.new()
    container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    container.offset_left = 10
    container.offset_top = 10
    container.offset_right = -10
    container.offset_bottom = -10

    # Header with event name and date
    var header = HBoxContainer.new()

    var event_label = Label.new()
    event_label.text = event.get("event", "Notable Event")
    event_label.add_theme_font_size_override("font_size", 14)
    event_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(event_label)

    var age_label = Label.new()
    age_label.text = "Age " + str(event.get("character_age", "?"))
    age_label.add_theme_font_size_override("font_size", 12)
    age_label.add_theme_color_override("font_color", Color.GRAY)
    header.add_child(age_label)

    # Delete button
    var delete_button = Button.new()
    delete_button.text = "×"
    delete_button.custom_minimum_size = Vector2(30, 30)
    delete_button.pressed.connect(func(): delete_timeline_event(event))
    header.add_child(delete_button)

    container.add_child(header)

    # Description
    if event.has("description") and event.description != "":
        var desc_label = Label.new()
        desc_label.text = event.description
        desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        desc_label.add_theme_font_size_override("font_size", 12)
        container.add_child(desc_label)

    panel.add_child(container)
    return panel

func _on_add_campaign_entry_pressed():
    """Show dialog to add a new campaign entry"""
    var dialog = AcceptDialog.new()
    dialog.title = "Add Campaign Entry"

    var container = VBoxContainer.new()

    # Title input
    var title_label = Label.new()
    title_label.text = "Session Title:"
    container.add_child(title_label)

    var title_input = LineEdit.new()
    title_input.placeholder_text = "e.g., Session 1: The Goblin Cave"
    container.add_child(title_input)

    # Content input
    var content_label = Label.new()
    content_label.text = "Session Notes:"
    container.add_child(content_label)

    var content_input = TextEdit.new()
    content_input.custom_minimum_size = Vector2(400, 200)
    content_input.placeholder_text = "What happened in this session? Key events, NPCs met, treasure found, etc."
    container.add_child(content_input)

    dialog.add_child(container)
    add_child(dialog)

    # Add OK button functionality
    dialog.confirmed.connect(func():
        var entry = {
            "title": title_input.text if title_input.text != "" else "Campaign Session",
            "content": content_input.text,
            "timestamp": Time.get_unix_time_from_system()
        }

        if not journal_data.has("campaign_entries"):
            journal_data.campaign_entries = []

        journal_data.campaign_entries.append(entry)
        update_campaign_entries()
        dialog.queue_free()
    )

    dialog.popup_centered()

func _on_add_timeline_event_pressed():
    """Show dialog to add a new timeline event"""
    var dialog = AcceptDialog.new()
    dialog.title = "Add Timeline Event"

    var container = VBoxContainer.new()

    # Event name input
    var event_label = Label.new()
    event_label.text = "Event Name:"
    container.add_child(event_label)

    var event_input = LineEdit.new()
    event_input.placeholder_text = "e.g., Born in Waterdeep, Became an Adventurer, etc."
    container.add_child(event_input)

    # Character age input
    var age_label = Label.new()
    age_label.text = "Character Age:"
    container.add_child(age_label)

    var age_input = SpinBox.new()
    age_input.min_value = 0
    age_input.max_value = 1000
    age_input.value = 18 # Default starting age
    container.add_child(age_input)

    # Description input
    var desc_label = Label.new()
    desc_label.text = "Description (optional):"
    container.add_child(desc_label)

    var desc_input = TextEdit.new()
    desc_input.custom_minimum_size = Vector2(400, 100)
    desc_input.placeholder_text = "Additional details about this event..."
    container.add_child(desc_input)

    dialog.add_child(container)
    add_child(dialog)

    # Add OK button functionality
    dialog.confirmed.connect(func():
        var event = {
            "event": event_input.text if event_input.text != "" else "Notable Event",
            "character_age": int(age_input.value),
            "description": desc_input.text,
            "timestamp": Time.get_unix_time_from_system()
        }

        if not journal_data.has("timeline_events"):
            journal_data.timeline_events = []

        journal_data.timeline_events.append(event)
        update_timeline_events()
        dialog.queue_free()
    )

    dialog.popup_centered()

func delete_campaign_entry(entry: Dictionary):
    """Delete a campaign entry"""
    var entries = journal_data.get("campaign_entries", [])
    entries.erase(entry)
    update_campaign_entries()

func delete_timeline_event(event: Dictionary):
    """Delete a timeline event"""
    var events = journal_data.get("timeline_events", [])
    events.erase(event)
    update_timeline_events()

func _on_save_button_pressed():
    """Save the journal"""
    save_journal_data()

    # Show confirmation
    var dialog = AcceptDialog.new()
    dialog.dialog_text = "Journal saved successfully!"
    add_child(dialog)
    dialog.popup_centered()

func _on_back_button_pressed():
    """Return to main screen"""
    # Auto-save before leaving
    save_journal_data()
    get_tree().change_scene_to_file("res://scenes/main.tscn")
