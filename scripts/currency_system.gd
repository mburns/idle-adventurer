extends Node

# Currency system for tracking gold and expenses

class_name CurrencySystem

signal gold_changed(character: Character, old_amount: float, new_amount: float)
signal expense_paid(character: Character, expense_type: String, amount: float)
signal income_earned(character: Character, income_type: String, amount: float)

# Currency conversion rates (in copper pieces)
const COPPER_PER_SILVER = 10
const SILVER_PER_GOLD = 10
const GOLD_PER_PLATINUM = 10

# Lifestyle expenses (per day in gold pieces)
var lifestyle_costs = {
    "wretched": 0.0,
    "squalid": 0.1,      # 1 sp = 0.1 gp
    "poor": 0.2,         # 2 sp = 0.2 gp
    "modest": 1.0,       # 1 gp
    "comfortable": 2.0,  # 2 gp
    "wealthy": 4.0,      # 4 gp
    "aristocratic": 10.0 # 10+ gp
}

var character_currencies: Dictionary = {}  # character_name -> currency_data

func _init():
    setup_currency_system()

func setup_currency_system():
    """Initialize the currency system"""
    # Set up daily expense timer
    var timer = Timer.new()
    timer.wait_time = 86400.0  # 24 hours in seconds
    timer.timeout.connect(_process_daily_expenses)
    timer.autostart = true
    add_child(timer)

func initialize_character_currency(character: Character, starting_gold: float = 0.0):
    """Initialize currency for a new character"""
    var currency_data = {
        "gold": starting_gold,
        "silver": 0.0,
        "copper": 0.0,
        "platinum": 0.0,
        "lifestyle": "modest",
        "total_earned": 0.0,
        "total_spent": 0.0
    }

    character_currencies[character.name] = currency_data
    character.gold = starting_gold

func add_gold(character: Character, amount: float, source: String = "unknown"):
    """Add gold to character's currency"""
    var old_amount = get_total_gold(character)
    var currency_data = character_currencies.get(character.name, {})

    if currency_data.is_empty():
        initialize_character_currency(character)
        currency_data = character_currencies[character.name]

    currency_data.gold += amount
    currency_data.total_earned += amount
    character.gold = currency_data.gold

    gold_changed.emit(character, old_amount, get_total_gold(character))
    income_earned.emit(character, source, amount)

    print(character.name + " earned " + str(amount) + " gp from " + source)

func spend_gold(character: Character, amount: float, expense_type: String = "purchase") -> bool:
    """Spend gold from character's currency"""
    var currency_data = character_currencies.get(character.name, {})

    if currency_data.is_empty():
        initialize_character_currency(character)
        currency_data = character_currencies[character.name]

    if currency_data.gold >= amount:
        var old_amount = get_total_gold(character)
        currency_data.gold -= amount
        currency_data.total_spent += amount
        character.gold = currency_data.gold

        gold_changed.emit(character, old_amount, get_total_gold(character))
        expense_paid.emit(character, expense_type, amount)

        print(character.name + " spent " + str(amount) + " gp on " + expense_type)
        return true
    else:
        print(character.name + " cannot afford " + str(amount) + " gp for " + expense_type)
        return false

func get_total_gold(character: Character) -> float:
    """Get total gold value for character"""
    var currency_data = character_currencies.get(character.name, {})

    if currency_data.is_empty():
        return 0.0

    var total = currency_data.gold
    total += currency_data.silver / SILVER_PER_GOLD
    total += currency_data.copper / (SILVER_PER_GOLD * COPPER_PER_SILVER)
    total += currency_data.platinum * GOLD_PER_PLATINUM

    return total

func get_currency_breakdown(character: Character) -> Dictionary:
    """Get detailed currency breakdown"""
    var currency_data = character_currencies.get(character.name, {})

    if currency_data.is_empty():
        return {
            "gold": 0.0,
            "silver": 0.0,
            "copper": 0.0,
            "platinum": 0.0,
            "total_gold_value": 0.0
        }

    return {
        "gold": currency_data.gold,
        "silver": currency_data.silver,
        "copper": currency_data.copper,
        "platinum": currency_data.platinum,
        "total_gold_value": get_total_gold(character)
    }

func set_lifestyle(character: Character, lifestyle: String):
    """Set character's lifestyle"""
    var currency_data = character_currencies.get(character.name, {})

    if currency_data.is_empty():
        initialize_character_currency(character)
        currency_data = character_currencies[character.name]

    currency_data.lifestyle = lifestyle
    print(character.name + " lifestyle set to " + lifestyle)

func get_lifestyle_cost(character: Character) -> float:
    """Get daily lifestyle cost for character"""
    var currency_data = character_currencies.get(character.name, {})

    if currency_data.is_empty():
        return lifestyle_costs["modest"]

    return lifestyle_costs.get(currency_data.lifestyle, lifestyle_costs["modest"])

func _process_daily_expenses():
    """Process daily lifestyle expenses for all characters"""
    for character_name in character_currencies.keys():
        var character = get_character_by_name(character_name)
        if character:
            var daily_cost = get_lifestyle_cost(character)
            if daily_cost > 0:
                spend_gold(character, daily_cost, "lifestyle expenses")

func get_character_by_name(name: String) -> Character:
    """Get character by name (placeholder - would use CharacterManager)"""
    # This would be implemented with proper character management
    return null

func can_afford(character: Character, amount: float) -> bool:
    """Check if character can afford an amount"""
    return get_total_gold(character) >= amount

func get_wealth_status(character: Character) -> String:
    """Get character's wealth status"""
    var total_gold = get_total_gold(character)

    if total_gold >= 1000:
        return "Very Wealthy"
    elif total_gold >= 500:
        return "Wealthy"
    elif total_gold >= 100:
        return "Comfortable"
    elif total_gold >= 50:
        return "Modest"
    elif total_gold >= 10:
        return "Poor"
    else:
        return "Destitute"

func get_currency_summary(character: Character) -> Dictionary:
    """Get comprehensive currency summary"""
    var currency_data = character_currencies.get(character.name, {})

    if currency_data.is_empty():
        return {
            "total_gold": 0.0,
            "lifestyle": "modest",
            "wealth_status": "Destitute",
            "total_earned": 0.0,
            "total_spent": 0.0,
            "net_worth": 0.0
        }

    return {
        "total_gold": get_total_gold(character),
        "lifestyle": currency_data.lifestyle,
        "wealth_status": get_wealth_status(character),
        "total_earned": currency_data.total_earned,
        "total_spent": currency_data.total_spent,
        "net_worth": currency_data.total_earned - currency_data.total_spent
    }

func convert_currency(character: Character, from_type: String, to_type: String, amount: float) -> bool:
    """Convert between currency types"""
    var currency_data = character_currencies.get(character.name, {})

    if currency_data.is_empty():
        return false

    var from_amount = currency_data.get(from_type, 0.0)
    if from_amount < amount:
        return false

    # Convert to gold value first
    var gold_value = 0.0
    match from_type:
        "copper":
            gold_value = amount / (SILVER_PER_GOLD * COPPER_PER_SILVER)
        "silver":
            gold_value = amount / SILVER_PER_GOLD
        "gold":
            gold_value = amount
        "platinum":
            gold_value = amount * GOLD_PER_PLATINUM

    # Convert to target type
    var converted_amount = 0.0
    match to_type:
        "copper":
            converted_amount = gold_value * SILVER_PER_GOLD * COPPER_PER_SILVER
        "silver":
            converted_amount = gold_value * SILVER_PER_GOLD
        "gold":
            converted_amount = gold_value
        "platinum":
            converted_amount = gold_value / GOLD_PER_PLATINUM

    # Update currency
    currency_data[from_type] -= amount
    currency_data[to_type] += converted_amount

    return true
