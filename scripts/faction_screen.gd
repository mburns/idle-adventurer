extends Control

# Faction screen for displaying faction information and reputation

var faction_system: FactionSystem
var current_character: Character

func _ready():
    # Apply theme
    ThemeManager.apply_theme_to_children(self)

    # Initialize faction system
    faction_system = FactionSystem.new()
    if not faction_system:
        print("Warning: Failed to create FactionSystem")
        return

    current_character = CharacterManager.current_character

    # Connect signals
    faction_system.reputation_changed.connect(_on_reputation_changed)
    faction_system.faction_quest_completed.connect(_on_quest_completed)

    # Update UI
    update_faction_display()

func update_faction_display():
    """Update the faction display with current data"""
    if not faction_system:
        print("Warning: FactionSystem is null")
        return

    var faction_tabs = %FactionTabs
    if not faction_tabs:
        print("Warning: FactionTabs not found")
        return

    # Get faction names
    var faction_names = faction_system.factions.keys()

    # Update each tab
    for i in range(faction_tabs.get_tab_count()):
        var tab_name = faction_tabs.get_tab_title(i)
        if tab_name in faction_names:
            update_faction_tab(tab_name, i)

func update_faction_tab(faction_name: String, tab_index: int):
    """Update a specific faction tab"""
    var tab_container = %FactionTabs.get_tab_control(tab_index)
    var reputation = faction_system.character_reputation.get(faction_name, 0)
    var reputation_level = faction_system.get_reputation_level_name(reputation)

    # Update reputation bar
    var reputation_bar = tab_container.get_node("VBoxContainer/FactionInfo/ReputationBar")
    reputation_bar.value = reputation + 100  # Convert -100 to 100 range to 0 to 200

    # Update reputation label
    var reputation_label = tab_container.get_node("VBoxContainer/FactionInfo/ReputationLabel")
    reputation_label.text = "Reputation: %d (%s)" % [reputation, reputation_level]

    # Update benefits
    update_faction_benefits(faction_name, tab_container)

    # Update quests
    update_faction_quests(faction_name, tab_container)

func update_faction_benefits(faction_name: String, tab_container: Control):
    """Update the benefits section for a faction"""
    var benefits_list = tab_container.get_node("VBoxContainer/BenefitsSection/BenefitsList")

    # Clear existing benefits
    for child in benefits_list.get_children():
        child.queue_free()

    # Get available benefits
    var benefits = faction_system.get_faction_benefits(faction_name)

    if benefits.is_empty():
        var no_benefits_label = Label.new()
        no_benefits_label.text = "No benefits available"
        no_benefits_label.add_theme_font_size_override("font_size", 12)
        benefits_list.add_child(no_benefits_label)
    else:
        for benefit in benefits:
            var benefit_label = Label.new()
            benefit_label.text = "• " + benefit
            benefit_label.add_theme_font_size_override("font_size", 12)
            benefit_label.add_theme_color_override("font_color", Color.GREEN)
            benefits_list.add_child(benefit_label)

func update_faction_quests(faction_name: String, tab_container: Control):
    """Update the quests section for a faction"""
    var quests_list = tab_container.get_node("VBoxContainer/QuestsSection/QuestsList")

    # Clear existing quests
    for child in quests_list.get_children():
        child.queue_free()

    # Get available quests
    var quests = faction_system.get_available_quests(faction_name)

    if quests.is_empty():
        var no_quests_label = Label.new()
        no_quests_label.text = "No quests available"
        no_quests_label.add_theme_font_size_override("font_size", 12)
        quests_list.add_child(no_quests_label)
    else:
        for quest in quests:
            var quest_container = HBoxContainer.new()
            quests_list.add_child(quest_container)

            var quest_label = Label.new()
            quest_label.text = "• " + quest
            quest_label.add_theme_font_size_override("font_size", 12)
            quest_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            quest_container.add_child(quest_label)

            var quest_button = Button.new()
            quest_button.text = "Complete"
            quest_button.add_theme_font_size_override("font_size", 10)
            quest_button.custom_minimum_size = Vector2(80, 30)
            quest_button.pressed.connect(func(): complete_quest(faction_name, quest))
            quest_container.add_child(quest_button)

func complete_quest(faction_name: String, quest_name: String):
    """Complete a faction quest"""
    var reputation_gained = faction_system.complete_faction_quest(faction_name, quest_name)

    # Show notification
    show_notification("Completed quest: %s\nGained %d reputation with %s" % [quest_name, reputation_gained, faction_name])

    # Update display
    update_faction_display()

func show_notification(message: String):
    """Show a notification popup"""
    var notification_popup = UIComponents.create_notification_popup(message)
    add_child(notification_popup)

    # Center the notification
    notification_popup.position = (get_viewport().size - notification_popup.size) / 2

func _on_reputation_changed(faction: String, new_reputation: int):
    """Handle reputation change"""
    print("Reputation with %s changed to %d" % [faction, new_reputation])
    update_faction_display()

func _on_quest_completed(faction: String, quest: String, reputation_gained: int):
    """Handle quest completion"""
    print("Completed quest '%s' for %s, gained %d reputation" % [quest, faction, reputation_gained])

func _on_back_button_pressed():
    """Return to main screen"""
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_test_quest_button_pressed():
    """Test quest completion for debugging"""
    # Complete a test quest for Harpers
    complete_quest("Harpers", "Investigate corruption")
