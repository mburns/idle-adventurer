extends Node

# D&D Currency System based on wiki/Equipment/Coinage.md

class_name CurrencySystem

signal currency_changed(character: Character, old_amount: Dictionary, new_amount: Dictionary)
signal currency_exchanged(character: Character, from_coin: String, to_coin: String, amount: int)

# Currency data loaded from YAML
var currency_data: Dictionary = {}  # coin_id -> coin_data
var exchange_rates: Dictionary = {}  # from_coin -> {to_coin: rate}
var coin_weights: Dictionary = {}    # coin_id -> weight

func _init() -> void:
    setup_currency_system()

func setup_currency_system() -> void:
    """Initialize the currency system"""
    load_currency_data()
    print("Currency System initialized")

func get_character_currency(character: Character) -> Dictionary:
    """Get character's currency amounts"""
    # Initialize currency dictionary if it doesn't exist
    if not character.has_method("get") or not character.currency.has("currencies"):
        character.currency = {"currencies": {}}

    return character.currency.get("currencies", {})

func add_currency(character: Character, coin_type: String, amount: int) -> void:
    """Add currency to character"""
    var old_currency = get_character_currency(character)

    # Initialize currency system if needed
    if not character.has_method("get") or not character.currency.has("currencies"):
        character.currency = {"currencies": {}}

    # Get current amount of this currency type
    var current_amount = character.currency.currencies.get(coin_type, 0)

    # Add the amount
    character.currency.currencies[coin_type] = current_amount + amount

    var new_currency = get_character_currency(character)
    currency_changed.emit(character, old_currency, new_currency)

    # Get coin name for display
    var coin_name = currency_data.get(coin_type, {}).get("name", coin_type)
    print(character.name + " gained " + str(amount) + " " + coin_name)

func remove_currency(character: Character, coin_type: String, amount: int) -> bool:
    """Remove currency from character"""
    # Initialize currency system if needed
    if not character.has_method("get") or not character.currency.has("currencies"):
        character.currency = {"currencies": {}}

    # Get current amount of this currency type
    var current_amount = character.currency.currencies.get(coin_type, 0)

    if current_amount < amount:
        var insufficient_coin_name = currency_data.get(coin_type, {}).get("name", coin_type)
        print("Insufficient " + insufficient_coin_name)
        return false

    var old_currency = get_character_currency(character)

    # Remove the amount
    character.currency.currencies[coin_type] = current_amount - amount

    var new_currency = get_character_currency(character)
    currency_changed.emit(character, old_currency, new_currency)

    # Get coin name for display
    var coin_name = currency_data.get(coin_type, {}).get("name", coin_type)
    print(character.name + " spent " + str(amount) + " " + coin_name)
    return true

func exchange_currency(character: Character, from_coin: String, to_coin: String, amount: int) -> bool:
    """Exchange currency between types"""
    if from_coin == to_coin:
        return true

    if not exchange_rates.has(from_coin) or not exchange_rates[from_coin].has(to_coin):
        print("Invalid currency exchange")
        return false

    var current_amount = 0
    match from_coin:
        "copper":
            current_amount = character.copper_pieces
        "silver":
            current_amount = character.silver_pieces
        "electrum":
            current_amount = character.electrum_pieces
        "gold":
            current_amount = character.gold_pieces
        "platinum":
            current_amount = character.platinum_pieces
    if current_amount < amount:
        print("Insufficient " + from_coin + " pieces")
        return false

    var exchange_rate = exchange_rates[from_coin][to_coin]
    var converted_amount = int(amount * exchange_rate)

    if converted_amount < 1:
        print("Exchange amount too small")
        return false

    # Remove original currency
    if not remove_currency(character, from_coin, amount):
        return false

    # Add converted currency
    add_currency(character, to_coin, converted_amount)

    currency_exchanged.emit(character, from_coin, to_coin, amount)
    print(character.name + " exchanged " + str(amount) + " " + from_coin + " for " + str(converted_amount) + " " + to_coin)

    return true

func get_total_value_in_gold(character: Character) -> float:
    """Get total currency value in gold pieces"""
    var currency = get_character_currency(character)
    var total_gp = 0.0

    for coin_type in currency.keys():
        var amount = currency[coin_type]
        var rate = exchange_rates[coin_type]["gp"]
        total_gp += amount * rate

    return total_gp

func get_total_weight(character: Character) -> float:
    """Get total currency weight in pounds"""
    var currency = get_character_currency(character)
    var total_weight = 0.0

    for coin_type in currency.keys():
        var amount = currency[coin_type]
        var weight_per_coin = coin_weights[coin_type]
        total_weight += amount * weight_per_coin

    return total_weight

func can_afford(character: Character, cost: Dictionary) -> bool:
    """Check if character can afford a cost"""
    var currency = get_character_currency(character)

    for coin_type in cost.keys():
        var required = cost[coin_type]
        var available = currency.get(coin_type, 0)

        if available < required:
            return false

    return true

func pay_cost(character: Character, cost: Dictionary) -> bool:
    """Pay a cost with character's currency"""
    if not can_afford(character, cost):
        return false

    for coin_type in cost.keys():
        var amount = cost[coin_type]
        if not remove_currency(character, coin_type, amount):
            return false

    return true

func get_currency_display(character: Character) -> String:
    """Get formatted currency display string"""
    var currency = get_character_currency(character)
    var display_parts = []

    # Only show non-zero amounts
    if currency["pp"] > 0:
        display_parts.append(str(currency["pp"]) + " pp")
    if currency["gp"] > 0:
        display_parts.append(str(currency["gp"]) + " gp")
    if currency["ep"] > 0:
        display_parts.append(str(currency["ep"]) + " ep")
    if currency["sp"] > 0:
        display_parts.append(str(currency["sp"]) + " sp")
    if currency["cp"] > 0:
        display_parts.append(str(currency["cp"]) + " cp")

    if display_parts.is_empty():
        return "No currency"

    return ", ".join(display_parts)

func get_currency_summary(character: Character) -> Dictionary:
    """Get currency summary for character"""
    var currency = get_character_currency(character)
    var total_gp = get_total_value_in_gold(character)
    var total_weight = get_total_weight(character)

    return {
        "currency": currency,
        "total_gold_value": total_gp,
        "total_weight": total_weight,
        "display_string": get_currency_display(character)
    }

func convert_to_gold_pieces(amount: int, from_coin: String) -> int:
    """Convert any currency amount to gold pieces"""
    if from_coin == "gp":
        return amount

    var rate = exchange_rates[from_coin]["gp"]
    return int(amount * rate)

func convert_from_gold_pieces(amount: int, to_coin: String) -> int:
    """Convert gold pieces to any other currency"""
    if to_coin == "gp":
        return amount

    var rate = exchange_rates["gp"][to_coin]
    return int(amount * rate)

func get_exchange_rate(from_coin: String, to_coin: String) -> float:
    """Get exchange rate between two coin types"""
    if from_coin == to_coin:
        return 1.0

    if not exchange_rates.has(from_coin) or not exchange_rates[from_coin].has(to_coin):
        return 0.0

    return exchange_rates[from_coin][to_coin]

func optimize_currency(character: Character):
    """Optimize character's currency by converting to higher denominations"""
    var currency = get_character_currency(character)

    # Convert copper to silver
    var cp = currency["cp"]
    if cp >= 10:
        var sp_converted = cp / 10
        character.copper_pieces = cp % 10
        add_currency(character, "sp", sp_converted)

    # Convert silver to electrum
    var sp = character.silver_pieces
    if sp >= 5:
        var ep_converted = sp / 5
        character.silver_pieces = sp % 5
        add_currency(character, "ep", ep_converted)

    # Convert electrum to gold
    var ep = character.electrum_pieces
    if ep >= 2:
        var gp_converted = ep / 2
        character.electrum_pieces = ep % 2
        add_currency(character, "gp", gp_converted)

    # Convert gold to platinum
    var gp = character.gold_pieces
    if gp >= 10:
        var pp_converted = gp / 10
        character.gold_pieces = gp % 10
        add_currency(character, "pp", pp_converted)

func get_coin_info(coin_type: String) -> Dictionary:
    """Get information about a coin type"""
    var coin_names = {
        "cp": "Copper Piece",
        "sp": "Silver Piece",
        "ep": "Electrum Piece",
        "gp": "Gold Piece",
        "pp": "Platinum Piece"
    }

    var coin_descriptions = {
        "cp": "Common among laborers and beggars. Buys a candle, torch, or piece of chalk.",
        "sp": "Most prevalent coin among commoners. Buys a laborer's work for half a day.",
        "ep": "From fallen empires and lost kingdoms. Sometimes arouses suspicion.",
        "gp": "Standard unit of measure for wealth. Buys a bedroll or 50 feet of rope.",
        "pp": "From fallen empires and lost kingdoms. Worth 10 gold pieces."
    }

    return {
        "name": coin_names.get(coin_type, "Unknown"),
        "description": coin_descriptions.get(coin_type, ""),
        "weight": coin_weights.get(coin_type, 0.02),
        "value_in_gp": exchange_rates[coin_type]["gp"] if exchange_rates.has(coin_type) else 0
    }

# YAML loading functions for currency system
func load_currency_data() -> void:
    """Load currency data from YAML file"""
    var file_path = "res://data/currency.yaml"
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        print("Error: Could not open currency file: " + file_path)
        return

    var yaml_string = file.get_as_text()
    file.close()

    var currency_config = parse_yaml_currency(yaml_string)
    if currency_config == null:
        print("Error parsing currency YAML")
        return

    # Load coin data
    var coins = currency_config.get("coins", [])
    for coin_data in coins:
        var coin_id = coin_data.get("id", "")
        if coin_id != "":
            currency_data[coin_id] = coin_data
            coin_weights[coin_id] = coin_data.get("weight", 0.02)

    # Load exchange rates
    var rates = currency_config.get("exchange_rates", {})
    for from_coin in rates.keys():
        exchange_rates[from_coin] = rates[from_coin]

    print("Loaded " + str(currency_data.size()) + " currency types")

func parse_yaml_currency(yaml_string: String) -> Dictionary:
    """Parse YAML currency configuration"""
    var lines = yaml_string.split("\n")
    var result = {}
    var current_key = ""
    var current_value = ""
    var in_multiline = false
    var indent_level = 0
    var current_array = []
    var in_array = false
    var current_object = {}
    var in_object = false
    var object_key = ""

    for line in lines:
        line = line.strip_edges()
        if line.is_empty() or line.begins_with("#"):
            continue

        var line_indent = get_indent_level(line)

        # Handle top-level keys
        if line_indent == 0 and ":" in line and not line.begins_with("-"):
            if in_multiline and current_key != "":
                result[current_key] = current_value.strip_edges()
                in_multiline = false

            var parts = line.split(":", 1)
            current_key = parts[0].strip_edges()
            var value = parts[1].strip_edges()

            if value.is_empty():
                in_multiline = true
                current_value = ""
            else:
                result[current_key] = parse_value(value)
        elif line.begins_with("- ") and line_indent == 0:
            # Handle array items (coins)
            if not in_array:
                in_array = true
                current_array = []
                result[current_key] = current_array

            # Start new object
            current_object = {}
            current_array.append(current_object)
            in_object = true
        elif line.begins_with("-") and line_indent > 0:
            # Handle nested array items
            var item = line.substr(1).strip_edges()
            if not current_object.has(object_key):
                current_object[object_key] = []
            current_object[object_key].append(parse_value(item))
        elif ":" in line and line_indent > 0:
            # Handle key-value pairs within objects
            if in_multiline and object_key != "":
                current_object[object_key] = current_object.get(object_key, "").strip_edges()
                in_multiline = false

            var parts = line.split(":", 1)
            object_key = parts[0].strip_edges()
            var value = parts[1].strip_edges()

            if value.is_empty():
                in_multiline = true
                current_object[object_key] = ""
            else:
                current_object[object_key] = parse_value(value)
        elif in_multiline and line_indent > indent_level:
            # Continue multiline value
            if in_object:
                current_object[object_key] += "\n" + line
            else:
                current_value += "\n" + line

    # Handle last key-value pair
    if in_multiline and current_key != "":
        result[current_key] = current_value.strip_edges()

    return result

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
