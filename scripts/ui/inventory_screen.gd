extends Control

# Inventory screen for managing character items with visual organization

var character: Character
var inventory_system: InventorySystem
var selected_item_id: String = ""
var item_buttons: Dictionary = {} # item_id -> button reference

func _ready():
    # Apply theme
    ThemeManager.apply_theme_to_children(self)

    # Get current character
    character = CharacterManager.current_character

    # Initialize inventory system
    inventory_system = InventorySystem.new()
    add_child(inventory_system)

    # Connect to inventory signals
    inventory_system.inventory_changed.connect(_on_inventory_changed)
    inventory_system.item_used.connect(_on_item_used)

    # Setup UI
    setup_filters()
    setup_sort_options()
    display_inventory()

func setup_filters():
    """Setup category filter dropdown"""
    var category_filter = %CategoryFilter
    category_filter.clear()

    category_filter.add_item("All Categories")
    category_filter.add_item("Weapons")
    category_filter.add_item("Armor")
    category_filter.add_item("Consumables")
    category_filter.add_item("Tools")
    category_filter.add_item("Adventuring Gear")
    category_filter.add_item("Treasure")
    category_filter.add_item("Spell Components")
    category_filter.add_item("Miscellaneous")

func setup_sort_options():
    """Setup sort dropdown"""
    var sort_dropdown = %SortDropdown
    sort_dropdown.clear()

    sort_dropdown.add_item("Name (A-Z)")
    sort_dropdown.add_item("Name (Z-A)")
    sort_dropdown.add_item("Type")
    sort_dropdown.add_item("Value (High-Low)")
    sort_dropdown.add_item("Value (Low-High)")
    sort_dropdown.add_item("Quantity (High-Low)")
    sort_dropdown.add_item("Weight (High-Low)")

func display_inventory():
    """Display character's inventory"""
    var grid_container = %GridContainer

    # Clear existing items
    for child in grid_container.get_children():
        child.queue_free()
    item_buttons.clear()

    # Get filtered and sorted items
    var items = get_filtered_items()
    var sorted_items = sort_items(items)

    if sorted_items.is_empty():
        var no_items_label = Label.new()
        no_items_label.text = "No items found matching your filters."
        no_items_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        no_items_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        grid_container.add_child(no_items_label)
        return

    # Create item buttons
    for item in sorted_items:
        var item_button = create_item_button(item)
        grid_container.add_child(item_button)
        item_buttons[item["inventory_id"]] = item_button

    # Update summary
    update_inventory_summary()

func create_item_button(item: Dictionary) -> Button:
    """Create a button for an inventory item"""
    var button = Button.new()
    button.custom_minimum_size = Vector2(100, 120)
    button.toggle_mode = true
    button.button_group = ButtonGroup.new()

    # Create item display container
    var container = VBoxContainer.new()
    container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    # Item icon/name
    var name_label = Label.new()
    name_label.text = item.get("name", "Unknown Item")
    name_label.add_theme_font_size_override("font_size", 12)
    name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    container.add_child(name_label)

    # Quantity (for stackable items)
    var quantity = item.get("quantity", 1)
    if quantity > 1:
        var quantity_label = Label.new()
        quantity_label.text = "x" + str(quantity)
        quantity_label.add_theme_font_size_override("font_size", 10)
        quantity_label.add_theme_color_override("font_color", Color.CYAN)
        quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        container.add_child(quantity_label)

    # Item type/rarity
    var type_label = Label.new()
    var item_type = item.get("type", "unknown").capitalize()
    var rarity = item.get("rarity", "common")
    type_label.text = item_type
    type_label.add_theme_font_size_override("font_size", 10)
    type_label.add_theme_color_override("font_color", get_rarity_color(rarity))
    type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    container.add_child(type_label)

    # Value
    var value = item.get("value", item.get("cost", 0))
    if value > 0:
        var value_label = Label.new()
        value_label.text = str(int(value)) + " gp"
        value_label.add_theme_font_size_override("font_size", 9)
        value_label.add_theme_color_override("font_color", Color.GOLD)
        value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        container.add_child(value_label)

    button.add_child(container)

    # Connect button signal
    button.pressed.connect(func(): select_item(item["inventory_id"]))

    return button

func get_rarity_color(rarity: String) -> Color:
    """Get color for item rarity"""
    match rarity:
        "common":
            return Color.WHITE
        "uncommon":
            return Color.GREEN
        "rare":
            return Color.BLUE
        "very_rare":
            return Color.PURPLE
        "legendary":
            return Color.GOLD
        _:
            return Color.WHITE

func select_item(item_id: String):
    """Select an item in the inventory"""
    selected_item_id = item_id

    # Update button appearance
    for id in item_buttons.keys():
        var button = item_buttons[id]
        button.button_pressed = (id == item_id)

    # Update action buttons
    update_action_buttons()

func update_action_buttons():
    """Update action buttons based on selected item"""
    var use_button = %UseItemButton
    var drop_button = %DropItemButton

    if selected_item_id != "":
        var inventory = inventory_system.get_character_inventory(character)
        var item = inventory["items"].get(selected_item_id, {})
        var item_type = item.get("type", "")

        # Enable/disable use button based on item type
        use_button.disabled = not can_use_item(item)
        use_button.text = get_use_button_text(item)

        drop_button.disabled = false
    else:
        use_button.disabled = true
        drop_button.disabled = true

func can_use_item(item: Dictionary) -> bool:
    """Check if an item can be used"""
    var item_type = item.get("type", "")
    return item_type in ["consumable", "potion", "food", "scroll"]

func get_use_button_text(item: Dictionary) -> String:
    """Get text for use button based on item type"""
    var item_type = item.get("type", "")

    match item_type:
        "consumable", "potion":
            return "Drink"
        "food":
            return "Eat"
        "scroll":
            return "Read"
        _:
            return "Use"

func get_filtered_items() -> Array:
    """Get items filtered by search and category"""
    var inventory = inventory_system.get_character_inventory(character)
    var items = []

    # Apply search filter
    var search_text = %SearchInput.text.to_lower()
    var category_filter = %CategoryFilter
    var selected_category = category_filter.get_item_text(category_filter.selected)

    for item_id in inventory["items"].keys():
        var item = inventory["items"][item_id]
        item["inventory_id"] = item_id

        # Search filter
        if search_text != "":
            var name = item.get("name", "").to_lower()
            var description = item.get("description", "").to_lower()
            if name.find(search_text) == -1 and description.find(search_text) == -1:
                continue

        # Category filter
        if selected_category != "All Categories":
            var item_category = inventory_system.get_item_category(item)
            var category_name = InventorySystem.ItemCategory.keys()[item_category]
            if category_name != selected_category:
                continue

        items.append(item)

    return items

func sort_items(items: Array) -> Array:
    """Sort items based on selected criteria"""
    var sort_dropdown = %SortDropdown
    var sort_option = sort_dropdown.get_item_text(sort_dropdown.selected)

    match sort_option:
        "Name (A-Z)":
            items.sort_custom(func(a, b): return a.get("name", "") < b.get("name", ""))
        "Name (Z-A)":
            items.sort_custom(func(a, b): return a.get("name", "") > b.get("name", ""))
        "Type":
            items.sort_custom(func(a, b): return a.get("type", "") < b.get("type", ""))
        "Value (High-Low)":
            items.sort_custom(func(a, b): return a.get("value", 0) > b.get("value", 0))
        "Value (Low-High)":
            items.sort_custom(func(a, b): return a.get("value", 0) < b.get("value", 0))
        "Quantity (High-Low)":
            items.sort_custom(func(a, b): return a.get("quantity", 0) > b.get("quantity", 0))
        "Weight (High-Low)":
            items.sort_custom(func(a, b): return a.get("weight", 0) > b.get("weight", 0))

    return items

func update_inventory_summary():
    """Update inventory summary display"""
    var summary = inventory_system.get_inventory_summary(character)
    var summary_text = "Inventory: " + str(summary["used_slots"]) + "/" + str(summary["max_slots"]) + " items"
    summary_text += " | Value: " + str(int(summary["total_value"])) + " gp"
    summary_text += " | Weight: " + str(int(summary["total_weight"])) + " lbs"

    %SummaryLabel.text = summary_text

func _on_search_text_changed(new_text: String):
    """Handle search text change"""
    display_inventory()

func _on_category_filter_selected(index: int):
    """Handle category filter selection"""
    display_inventory()

func _on_sort_dropdown_selected(index: int):
    """Handle sort dropdown selection"""
    display_inventory()

func _on_use_item_button_pressed():
    """Handle use item button press"""
    if selected_item_id != "":
        var quantity = 1 # For now, use 1 item at a time

        # Show quantity dialog for stackable items
        var inventory = inventory_system.get_character_inventory(character)
        var item = inventory["items"].get(selected_item_id, {})
        var max_quantity = item.get("quantity", 1)

        if max_quantity > 1:
            show_quantity_dialog("Use Item", "How many would you like to use?", max_quantity, func(qty): use_item(qty))
        else:
            use_item(1)

func _on_drop_item_button_pressed():
    """Handle drop item button press"""
    if selected_item_id != "":
        var inventory = inventory_system.get_character_inventory(character)
        var item = inventory["items"].get(selected_item_id, {})
        var max_quantity = item.get("quantity", 1)

        if max_quantity > 1:
            show_quantity_dialog("Drop Item", "How many would you like to drop?", max_quantity, func(qty): drop_item(qty))
        else:
            drop_item(1)

func use_item(quantity: int):
    """Use the selected item"""
    if inventory_system.use_item(character, selected_item_id, quantity):
        selected_item_id = ""
        display_inventory()

func drop_item(quantity: int):
    """Drop the selected item"""
    if inventory_system.remove_item(character, selected_item_id, quantity):
        selected_item_id = ""
        display_inventory()

func show_quantity_dialog(title: String, message: String, max_quantity: int, callback: Callable):
    """Show dialog for selecting quantity"""
    var dialog = AcceptDialog.new()
    dialog.title = title

    var container = VBoxContainer.new()

    var message_label = Label.new()
    message_label.text = message
    container.add_child(message_label)

    var quantity_input = SpinBox.new()
    quantity_input.min_value = 1
    quantity_input.max_value = max_quantity
    quantity_input.value = 1
    container.add_child(quantity_input)

    dialog.add_child(container)
    add_child(dialog)

    dialog.confirmed.connect(func(): callback.call(quantity_input.value))
    dialog.popup_centered()

func _on_inventory_changed(character: Character):
    """Handle inventory changed signal"""
    display_inventory()

func _on_item_used(character: Character, item: Dictionary, quantity: int):
    """Handle item used signal"""
    print("Used " + str(quantity) + "x " + item.get("name", "Unknown Item"))

func _on_back_button_pressed():
    """Return to main screen"""
    get_tree().change_scene_to_file("res://scenes/main.tscn")
