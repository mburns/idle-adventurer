class_name Location
extends Resource

# Locations within towns and cities

# Use global LocationType enum from location_type.gd

@export var location_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var location_type: LocationType.Type = LocationType.Type.TAVERN
@export var town_id: String = ""
@export var coordinates: Vector2 = Vector2.ZERO
@export var size: String = "medium"  # small, medium, large, huge
@export var capacity: int = 50  # Maximum number of people
@export var current_occupancy: int = 0
@export var services: Array[String] = []  # Available services
@export var npcs: Array[String] = []  # NPC IDs present
@export var items: Array[String] = []  # Items available here
@export var requirements: Dictionary = {}  # Access requirements
@export var restrictions: Dictionary = {}  # Access restrictions
@export var hours: Dictionary = {}  # Operating hours
@export var atmosphere: Dictionary = {}  # Environmental details
@export var events: Array[String] = []  # Events that can occur here
@export var connections: Array[String] = []  # Connected location IDs
@export var cost: Dictionary = {}  # Costs for services/access
@export var reputation_required: Dictionary = {}  # Reputation requirements

func get_location_type_string() -> String:
	"""Get location type as string"""
	match location_type:
		LocationType.Type.TAVERN:
			return "Tavern"
		LocationType.Type.INN:
			return "Inn"
		LocationType.Type.SHOP:
			return "Shop"
		LocationType.Type.BLACKSMITH:
			return "Blacksmith"
		LocationType.Type.LIBRARY:
			return "Library"
		LocationType.Type.TEMPLE:
			return "Temple"
		LocationType.Type.GUILD_HALL:
			return "Guild Hall"
		LocationType.Type.MARKET:
			return "Market"
		LocationType.Type.TOWN_HALL:
			return "Town Hall"
		LocationType.Type.GUARD_POST:
			return "Guard Post"
		LocationType.Type.RESIDENTIAL:
			return "Residential"
		LocationType.Type.WAREHOUSE:
			return "Warehouse"
		LocationType.Type.STABLE:
			return "Stable"
		LocationType.Type.APOTHECARY:
			return "Apothecary"
		LocationType.Type.BANK:
			return "Bank"
		LocationType.Type.THEATER:
			return "Theater"
		LocationType.Type.ARENA:
			return "Arena"
		LocationType.Type.PARK:
			return "Park"
		LocationType.Type.BRIDGE:
			return "Bridge"
		LocationType.Type.GATE:
			return "Gate"
		LocationType.Type.WALL:
			return "Wall"
		LocationType.Type.TOWER:
			return "Tower"
		LocationType.Type.CASTLE:
			return "Castle"
		LocationType.Type.MANOR:
			return "Manor"
		LocationType.Type.COTTAGE:
			return "Cottage"
		LocationType.Type.FARM:
			return "Farm"
		LocationType.Type.MILL:
			return "Mill"
		LocationType.Type.QUARRY:
			return "Quarry"
		LocationType.Type.MINE:
			return "Mine"
		LocationType.Type.FOREST:
			return "Forest"
		LocationType.Type.MOUNTAIN:
			return "Mountain"
		LocationType.Type.RIVER:
			return "River"
		LocationType.Type.LAKE:
			return "Lake"
		LocationType.Type.CAVE:
			return "Cave"
		LocationType.Type.RUINS:
			return "Ruins"
		LocationType.Type.ROAD:
			return "Road"
		LocationType.Type.PATH:
			return "Path"
		LocationType.Type.TRAIL:
			return "Trail"
		_:
			return "Unknown"

func is_accessible(character: Character) -> bool:
	"""Check if character can access this location"""
	if requirements.is_empty():
		return true

	for req_type in requirements.keys():
		var required_value = requirements[req_type]

		match req_type:
			"level":
				if character.level < required_value:
					return false
			"gold":
				if character.gold < required_value:
					return false
			"reputation":
				if character.faction_reputation.has(required_value):
					var current_reputation = character.faction_reputation[required_value]
					if current_reputation < required_value:
						return false
			"faction":
				if not character.faction_reputation.has(required_value):
					return false
			"quest_completed":
				# Check if character has completed required quest
				pass  # Would integrate with quest system

	return true

func has_service(service_name: String) -> bool:
	"""Check if this location provides a specific service"""
	return service_name in services

func get_service_cost(service_name: String) -> int:
	"""Get cost for a specific service"""
	return cost.get(service_name, 0)

func is_open_at_time(hour: int) -> bool:
	"""Check if location is open at a specific hour"""
	if hours.is_empty():
		return true

	if hours.has("always_open"):
		return hours["always_open"]

	if hours.has("open_hours"):
		var open_hours = hours["open_hours"]
		if open_hours.has("start") and open_hours.has("end"):
			return hour >= open_hours["start"] and hour <= open_hours["end"]

	return true

func get_atmosphere_description() -> String:
	"""Get atmospheric description of the location"""
	if atmosphere.has("description"):
		return atmosphere["description"]

	# Generate description based on type
	match location_type:
		LocationType.Type.TAVERN:
			return "A warm, bustling tavern filled with the sounds of conversation and laughter."
		LocationType.Type.INN:
			return "A comfortable inn offering rest and shelter to weary travelers."
		LocationType.Type.SHOP:
			return "A well-stocked shop with various goods for sale."
		LocationType.Type.BLACKSMITH:
			return "A hot, noisy forge where metal is shaped into tools and weapons."
		LocationType.Type.LIBRARY:
			return "A quiet library filled with books and scrolls of knowledge."
		LocationType.Type.TEMPLE:
			return "A peaceful temple dedicated to the divine."
		LocationType.Type.MARKET:
			return "A busy marketplace filled with vendors and customers."
		_:
			return "A typical location in the town."

func can_accommodate_additional_people(count: int = 1) -> bool:
	"""Check if location can accommodate additional people"""
	return (current_occupancy + count) <= capacity

func add_person():
	"""Add a person to the location"""
	if can_accommodate_additional_people():
		current_occupancy += 1

func remove_person():
	"""Remove a person from the location"""
	if current_occupancy > 0:
		current_occupancy -= 1
