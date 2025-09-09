extends Node

# D&D Currency System based on wiki/Equipment/Coinage.md

class_name CurrencySystem

signal currency_changed(character: Character, old_amount: Dictionary, new_amount: Dictionary)
signal currency_exchanged(character: Character, from_coin: String, to_coin: String, amount: int)

# Exchange rates based on D&D rules
var exchange_rates = {
    "cp": {"sp": 0.1, "ep": 0.02, "gp": 0.01, "pp": 0.001},
    "sp": {"cp": 10, "ep": 0.2, "gp": 0.1, "pp": 0.01},
    "ep": {"cp": 50, "sp": 5, "gp": 0.5, "pp": 0.05},
    "gp": {"cp": 100, "sp": 10, "ep": 2, "pp": 0.1},
    "pp": {"cp": 1000, "sp": 100, "ep": 20, "gp": 10}
}

# Coin weights (in pounds per coin)
var coin_weights = {
    "cp": 0.02, # 50 coins = 1 pound
    "sp": 0.02,
    "ep": 0.02,
    "gp": 0.02,
    "pp": 0.02
}

func _init():
    setup_currency_system()

func setup_currency_system():
    """Initialize the currency system"""
    print("Currency System initialized")

func get_character_currency(character: Character) -> Dictionary:
    """Get character's currency amounts"""
    return {
        "cp": character.copper_pieces,
        "sp": character.silver_pieces,
        "ep": character.electrum_pieces,
        "gp": character.gold_pieces,
        "pp": character.platinum_pieces
    }

func add_currency(character: Character, coin_type: String, amount: int):
    """Add currency to character"""
    var old_currency = get_character_currency(character)

    var current_amount = 0
    match coin_type:
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

    match coin_type:
        "copper":
            character.copper_pieces = current_amount + amount
        "silver":
            character.silver_pieces = current_amount + amount
        "electrum":
            character.electrum_pieces = current_amount + amount
        "gold":
            character.gold_pieces = current_amount + amount
        "platinum":
            character.platinum_pieces = current_amount + amount

    var new_currency = get_character_currency(character)
    currency_changed.emit(character, old_currency, new_currency)

    print(character.name + " gained " + str(amount) + " " + coin_type)

func remove_currency(character: Character, coin_type: String, amount: int) -> bool:
    """Remove currency from character"""
    var current_amount = 0
    match coin_type:
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
        print("Insufficient " + coin_type + " pieces")
        return false

    var old_currency = get_character_currency(character)
    match coin_type:
        "copper":
            character.copper_pieces = current_amount - amount
        "silver":
            character.silver_pieces = current_amount - amount
        "electrum":
            character.electrum_pieces = current_amount - amount
        "gold":
            character.gold_pieces = current_amount - amount
        "platinum":
            character.platinum_pieces = current_amount - amount

    var new_currency = get_character_currency(character)
    currency_changed.emit(character, old_currency, new_currency)

    print(character.name + " spent " + str(amount) + " " + coin_type)
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
