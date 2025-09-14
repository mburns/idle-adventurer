extends Control

# General Store screen for purchasing items and banking

var character: Character
var general_store: GeneralStore
var filtered_items: Dictionary = {}

func _ready():
    # Apply theme
    ThemeManager.apply_theme_to_children(self)

    # Get current character
    character = CharacterManager.current_character

    # Initialize general store
    general_store = GeneralStore.new()
    add_child(general_store)

    # Connect to store signals
    general_store.item_purchased.connect(_on_item_purchased)
    general_store.bank_deposit.connect(_on_bank_deposit)
    general_store.bank_withdrawal.connect(_on_bank_withdrawal)

    # Setup UI
    setup_filters()
    setup_bank_ui()
    display_items()

func setup_filters():
    """Setup filter dropdowns"""
    var type_filter = %TypeFilter
    var rarity_filter = %RarityFilter

    # Type filter
    type_filter.clear()
    type_filter.add_item("All Types")
    type_filter.add_item("Consumables")
    type_filter.add_item("Adventuring Gear")
    type_filter.add_item("Tools")
    type_filter.add_item("Weapons")
    type_filter.add_item("Armor")

    # Rarity filter
    rarity_filter.clear()
    rarity_filter.add_item("All Rarities")
    rarity_filter.add_item("Common")
    rarity_filter.add_item("Uncommon")
    rarity_filter.add_item("Rare")
    rarity_filter.add_item("Very Rare")
    rarity_filter.add_item("Legendary")

func setup_bank_ui():
    """Setup bank UI with current balances"""
    update_bank_display()

func display_items():
    """Display items in the store"""
    var item_container = %ItemContainer

    # Clear existing items
    for child in item_container.get_children():
        child.queue_free()

    # Get filtered items
    var items_to_show = get_filtered_items()

    if items_to_show.is_empty():
        var no_items_label = Label.new()
        no_items_label.text = "No items found matching your filters."
        no_items_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        item_container.add_child(no_items_label)
        return

    # Display items
    for item_id in items_to_show.keys():
        var item = items_to_show[item_id]
        var item_panel = create_item_panel(item_id, item)
        item_container.add_child(item_panel)

func get_filtered_items() -> Dictionary:
    """Get items based on current filters"""
    var all_items = general_store.get_store_inventory()
    var filtered = {}

    # Apply search filter
    var search_text = %SearchInput.text.to_lower()
    if search_text != "":
        for item_id in all_items.keys():
            var item = all_items[item_id]
            var name = item.get("name", "").to_lower()
            var description = item.get("description", "").to_lower()

            if name.find(search_text) != -1 or description.find(search_text) != -1:
                filtered[item_id] = item
    else:
        filtered = all_items.duplicate()

    # Apply type filter
    var type_filter = %TypeFilter
    var selected_type = type_filter.get_item_text(type_filter.selected)
    if selected_type != "All Types":
        var type_to_filter = selected_type.to_lower().replace(" ", "_")
        var type_filtered = {}
        for item_id in filtered.keys():
            var item = filtered[item_id]
            if item.get("type", "") == type_to_filter:
                type_filtered[item_id] = item
        filtered = type_filtered

    # Apply rarity filter
    var rarity_filter = %RarityFilter
    var selected_rarity = rarity_filter.get_item_text(rarity_filter.selected)
    if selected_rarity != "All Rarities":
        var rarity_to_filter = selected_rarity.to_lower()
        var rarity_filtered = {}
        for item_id in filtered.keys():
            var item = filtered[item_id]
            if item.get("rarity", "") == rarity_to_filter:
                rarity_filtered[item_id] = item
        filtered = rarity_filtered

    return filtered

func create_item_panel(item_id: String, item: Dictionary) -> Panel:
    """Create a panel for an item"""
    var panel = Panel.new()
    panel.custom_minimum_size = Vector2(0, 100)

    var container = VBoxContainer.new()
    container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    container.offset_left = 10
    container.offset_top = 10
    container.offset_right = -10
    container.offset_bottom = -10

    # Header with item name and cost
    var header = HBoxContainer.new()

    var name_label = Label.new()
    name_label.text = item["name"]
    name_label.add_theme_font_size_override("font_size", 16)
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(name_label)

    var cost_label = Label.new()
    cost_label.text = str(item["cost"]) + " gp"
    cost_label.add_theme_font_size_override("font_size", 14)
    cost_label.add_theme_color_override("font_color", Color.GOLD)
    header.add_child(cost_label)

    container.add_child(header)

    # Description
    var desc_label = Label.new()
    desc_label.text = item["description"]
    desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc_label.add_theme_font_size_override("font_size", 12)
    container.add_child(desc_label)

    # Type and rarity info
    var info_container = HBoxContainer.new()

    var type_label = Label.new()
    type_label.text = item.get("type", "unknown").capitalize()
    type_label.add_theme_font_size_override("font_size", 11)
    type_label.add_theme_color_override("font_color", Color.CYAN)
    info_container.add_child(type_label)

    var rarity_label = Label.new()
    var rarity = item.get("rarity", "common")
    rarity_label.text = rarity.capitalize()
    rarity_label.add_theme_font_size_override("font_size", 11)
    rarity_label.add_theme_color_override("font_color", get_rarity_color(rarity))
    info_container.add_child(rarity_label)

    container.add_child(info_container)

    # Purchase button
    var button_container = HBoxContainer.new()

    var quantity_input = SpinBox.new()
    quantity_input.min_value = 1
    quantity_input.max_value = 99
    quantity_input.value = 1
    quantity_input.custom_minimum_size = Vector2(60, 0)
    button_container.add_child(quantity_input)

    var purchase_button = Button.new()
    var can_afford = character.gold >= item["cost"]
    purchase_button.text = "Buy" if can_afford else "Can't Afford"
    purchase_button.disabled = not can_afford
    purchase_button.add_theme_color_override("font_color", Color.GREEN if can_afford else Color.RED)
    purchase_button.pressed.connect(func(): purchase_item(item_id, int(quantity_input.value)))
    button_container.add_child(purchase_button)

    container.add_child(button_container)

    panel.add_child(container)
    return panel

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

func purchase_item(item_id: String, quantity: int):
    """Purchase an item"""
    if general_store.purchase_item(character, item_id, quantity):
        update_bank_display()
        display_items() # Refresh to update affordability

func update_bank_display():
    """Update bank display with current balances"""
    var bank_balance = general_store.get_character_bank_balance(character)
    var wealth_info = general_store.get_character_wealth(character)
    var wealth_tier = general_store.get_wealth_tier(character)

    %BalanceLabel.text = "Bank Balance: " + str(int(bank_balance)) + " gp"
    %WealthLabel.text = "Total Wealth: " + str(int(wealth_info["total_wealth"])) + " gp (" + wealth_tier + ")"

    # Update input limits
    %DepositInput.max_value = character.gold
    %WithdrawInput.max_value = bank_balance

func _on_search_text_changed(new_text: String):
    """Handle search text change"""
    display_items()

func _on_type_filter_selected(index: int):
    """Handle type filter selection"""
    display_items()

func _on_rarity_filter_selected(index: int):
    """Handle rarity filter selection"""
    display_items()

func _on_deposit_button_pressed():
    """Handle deposit button press"""
    var amount = %DepositInput.value
    if amount > 0:
        if general_store.deposit_to_bank(character, amount):
            update_bank_display()

func _on_withdraw_button_pressed():
    """Handle withdraw button press"""
    var amount = %WithdrawInput.value
    if amount > 0:
        if general_store.withdraw_from_bank(character, amount):
            update_bank_display()
            display_items() # Refresh to update affordability

func _on_item_purchased(character: Character, item: Dictionary, cost: float):
    """Handle item purchased signal"""
    print("Purchased: " + item["name"] + " for " + str(cost) + " gp")

func _on_bank_deposit(character: Character, amount: float):
    """Handle bank deposit signal"""
    print("Deposited: " + str(amount) + " gp to bank")

func _on_bank_withdrawal(character: Character, amount: float):
    """Handle bank withdrawal signal"""
    print("Withdrew: " + str(amount) + " gp from bank")

func _on_back_button_pressed():
    """Return to main screen"""
    get_tree().change_scene_to_file("res://scenes/main.tscn")
