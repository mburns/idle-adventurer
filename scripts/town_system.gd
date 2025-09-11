extends Node

# Town locations and local services system for idle D&D gameplay
# Handles town locations, services, and local activities

class_name TownSystem

signal location_visited(character: Character, location: String)
signal service_used(character: Character, service: String, cost: int)
signal town_event_triggered(event: TownEvent)

# Location types
enum LocationType {
	MARKET, # Market square, shops
	TAVERN, # Taverns, inns
	GUILD_HALL, # Professional guilds
	TEMPLE, # Religious buildings
	LIBRARY, # Knowledge centers
	SMITHY, # Crafting workshops
	TOWN_HALL, # Government buildings
	GUARD_BARRACKS, # Military facilities
	NOBLE_DISTRICT, # Wealthy areas
	RESIDENTIAL, # Housing areas
	WAREHOUSE, # Storage facilities
	STABLE # Animal care
}

# Service types
enum ServiceType {
	SHOPPING, # Buying and selling goods
	ACCOMMODATION, # Lodging and meals
	TRAINING, # Skill and ability training
	HEALING, # Medical and magical healing
	INFORMATION, # Gathering information
	TRANSPORTATION, # Travel services
	STORAGE, # Item storage
	COMMUNICATION, # Sending messages
	ENTERTAINMENT, # Recreation and fun
	ADMINISTRATION # Official services
}

# Town event types
enum TownEventType {
	MARKET_DAY, # Special market events
	FESTIVAL, # Town celebrations
	EMERGENCY, # Crisis situations
	VISITOR, # Important visitors
	CONSTRUCTION, # Building projects
	TRADE_DEAL, # Commercial opportunities
	CRIME_WAVE, # Increased criminal activity
	WEATHER_EVENT, # Weather-related events
	POLITICAL_EVENT, # Government changes
	RELIGIOUS_EVENT # Religious ceremonies
}

# Location data structure
class Location:
	var id: String
	var name: String
	var location_type: LocationType
	var description: String
	var services: Array[String] = [] # Available services
	var npcs: Array[String] = [] # NPCs found here
	var requirements: Dictionary = {} # Access requirements
	var costs: Dictionary = {} # Service costs
	var hours: Dictionary = {} # Operating hours
	var reputation_required: int = 0 # Minimum reputation needed

	func _init(loc_id: String, loc_name: String, loc_type: LocationType):
		id = loc_id
		name = loc_name
		location_type = loc_type

# Service data structure
class Service:
	var id: String
	var name: String
	var service_type: ServiceType
	var description: String
	var location: String # Where service is available
	var cost: int = 0
	var requirements: Dictionary = {}
	var benefits: Dictionary = {}
	var duration_hours: int = 1

	func _init(serv_id: String, serv_name: String, serv_type: ServiceType):
		id = serv_id
		name = serv_name
		service_type = serv_type

# Town event data structure
class TownEvent:
	var id: String
	var name: String
	var event_type: TownEventType
	var description: String
	var duration_days: int = 1
	var effects: Dictionary = {} # Effects on town
	var requirements: Dictionary = {} # Requirements to participate
	var rewards: Dictionary = {} # Rewards for participation

	func _init(event_id: String, event_name: String, event_type: TownEventType):
		id = event_id
		name = event_name
		event_type = event_type

var locations: Dictionary = {} # location_id -> Location
var services: Dictionary = {} # service_id -> Service
var town_events: Dictionary = {} # event_id -> TownEvent
var active_events: Array[String] = [] # Currently active events

func _init():
	setup_town_locations()
	setup_town_services()
	setup_town_events()

func setup_town_locations():
	"""Initialize town locations"""
	create_market_locations()
	create_tavern_locations()
	create_guild_locations()
	create_temple_locations()
	create_library_locations()
	create_smithy_locations()
	create_government_locations()
	create_military_locations()
	create_noble_locations()
	create_residential_locations()

func create_market_locations():
	"""Create market and shopping locations"""
	var market_square = Location.new("market_square", "Market Square", LocationType.MARKET)
	market_square.description = "The bustling heart of the town's commerce"
	market_square.services = ["general_shopping", "food_vendor", "information_broker"]
	market_square.npcs = ["general_store", "spy"]
	market_square.hours = {"morning": "open", "afternoon": "open", "evening": "closed"}
	market_square.costs = {"general_shopping": 0, "food_vendor": 5, "information_broker": 10}
	locations["market_square"] = market_square

	var artisan_quarter = Location.new("artisan_quarter", "Artisan Quarter", LocationType.MARKET)
	artisan_quarter.description = "Where skilled craftsmen ply their trade"
	artisan_quarter.services = ["custom_crafting", "artisan_goods", "repair_services"]
	artisan_quarter.npcs = ["jeweler"]
	artisan_quarter.hours = {"morning": "open", "afternoon": "open", "evening": "closed"}
	artisan_quarter.costs = {"custom_crafting": 50, "artisan_goods": 25, "repair_services": 15}
	locations["artisan_quarter"] = artisan_quarter

func create_tavern_locations():
	"""Create tavern and inn locations"""
	var golden_harp = Location.new("golden_harp", "The Golden Harp Tavern", LocationType.TAVERN)
	golden_harp.description = "A warm and welcoming tavern known for its music"
	golden_harp.services = ["accommodation", "meals", "entertainment", "social_gathering"]
	golden_harp.npcs = ["bard", "ranger"]
	golden_harp.hours = {"morning": "open", "afternoon": "open", "evening": "open"}
	golden_harp.costs = {"accommodation": 2, "meals": 1, "entertainment": 3, "social_gathering": 0}
	locations["golden_harp"] = golden_harp

	var travelers_rest = Location.new("travelers_rest", "Traveler's Rest Inn", LocationType.TAVERN)
	travelers_rest.description = "A simple but clean inn for travelers"
	travelers_rest.services = ["accommodation", "meals", "stable_service"]
	travelers_rest.npcs = []
	travelers_rest.hours = {"morning": "open", "afternoon": "open", "evening": "open"}
	travelers_rest.costs = {"accommodation": 1, "meals": 0.5, "stable_service": 1}
	locations["travelers_rest"] = travelers_rest

func create_guild_locations():
	"""Create guild hall locations"""
	var craftsman_guild = Location.new("craftsman_guild", "Craftsman Guild Hall", LocationType.GUILD_HALL)
	craftsman_guild.description = "The headquarters of the local craftsman guild"
	craftsman_guild.services = ["guild_membership", "training", "trade_opportunities"]
	craftsman_guild.npcs = ["blacksmith"]
	craftsman_guild.hours = {"morning": "open", "afternoon": "open", "evening": "closed"}
	craftsman_guild.costs = {"guild_membership": 100, "training": 25, "trade_opportunities": 0}
	craftsman_guild.reputation_required = 20
	locations["craftsman_guild"] = craftsman_guild

func create_temple_locations():
	"""Create temple locations"""
	var temple = Location.new("temple", "Temple of the Light", LocationType.TEMPLE)
	temple.description = "A beautiful temple dedicated to the gods of light and healing"
	temple.services = ["healing", "spiritual_guidance", "religious_services", "donations"]
	temple.npcs = ["priest"]
	temple.hours = {"morning": "open", "afternoon": "open", "evening": "open"}
	temple.costs = {"healing": 10, "spiritual_guidance": 0, "religious_services": 0, "donations": 0}
	locations["temple"] = temple

func create_library_locations():
	"""Create library locations"""
	var library = Location.new("library", "Town Library", LocationType.LIBRARY)
	library.description = "A repository of knowledge and learning"
	library.services = ["research", "book_access", "language_learning", "quiet_study"]
	library.npcs = ["librarian"]
	library.hours = {"morning": "open", "afternoon": "open", "evening": "closed"}
	library.costs = {"research": 5, "book_access": 2, "language_learning": 15, "quiet_study": 0}
	locations["library"] = library

func create_smithy_locations():
	"""Create smithy locations"""
	var smithy = Location.new("smithy", "Ironforge Smithy", LocationType.SMITHY)
	smithy.description = "A well-equipped forge for metalworking"
	smithy.services = ["weapon_crafting", "armor_repair", "tool_making", "metalwork_training"]
	smithy.npcs = ["blacksmith"]
	smithy.hours = {"morning": "open", "afternoon": "open", "evening": "closed"}
	smithy.costs = {"weapon_crafting": 75, "armor_repair": 25, "tool_making": 30, "metalwork_training": 20}
	locations["smithy"] = smithy

func create_government_locations():
	"""Create government locations"""
	var town_hall = Location.new("town_hall", "Town Hall", LocationType.TOWN_HALL)
	town_hall.description = "The center of local government and administration"
	town_hall.services = ["legal_advice", "permits", "official_documents", "town_meetings"]
	town_hall.npcs = ["mayor"]
	town_hall.hours = {"morning": "open", "afternoon": "open", "evening": "closed"}
	town_hall.costs = {"legal_advice": 20, "permits": 10, "official_documents": 5, "town_meetings": 0}
	town_hall.reputation_required = 10
	locations["town_hall"] = town_hall

func create_military_locations():
	"""Create military locations"""
	var guard_barracks = Location.new("guard_barracks", "Guard Barracks", LocationType.GUARD_BARRACKS)
	guard_barracks.description = "The headquarters of the town guard"
	guard_barracks.services = ["combat_training", "security_advice", "patrol_duty", "guard_recruitment"]
	guard_barracks.npcs = ["guard_captain"]
	guard_barracks.hours = {"morning": "open", "afternoon": "open", "evening": "closed"}
	guard_barracks.costs = {"combat_training": 30, "security_advice": 15, "patrol_duty": 0, "guard_recruitment": 0}
	guard_barracks.reputation_required = 15
	locations["guard_barracks"] = guard_barracks

func create_noble_locations():
	"""Create noble district locations"""
	var noble_manor = Location.new("noble_manor", "Noble Manor", LocationType.NOBLE_DISTRICT)
	noble_manor.description = "The residence of the local nobility"
	noble_manor.services = ["noble_audience", "luxury_goods", "political_advice", "social_events"]
	noble_manor.npcs = ["luxury_merchant"]
	noble_manor.hours = {"morning": "closed", "afternoon": "open", "evening": "open"}
	noble_manor.costs = {"noble_audience": 50, "luxury_goods": 100, "political_advice": 75, "social_events": 25}
	noble_manor.reputation_required = 50
	locations["noble_manor"] = noble_manor

func create_residential_locations():
	"""Create residential locations"""
	var residential_district = Location.new("residential_district", "Residential District", LocationType.RESIDENTIAL)
	residential_district.description = "The quiet residential area of the town"
	residential_district.services = ["housing", "neighborhood_watch", "community_events"]
	residential_district.npcs = []
	residential_district.hours = {"morning": "open", "afternoon": "open", "evening": "open"}
	residential_district.costs = {"housing": 5, "neighborhood_watch": 0, "community_events": 0}
	locations["residential_district"] = residential_district

func setup_town_services():
	"""Initialize town services"""
	create_shopping_services()
	create_accommodation_services()
	create_training_services()
	create_healing_services()
	create_information_services()
	create_entertainment_services()
	create_administration_services()

func create_shopping_services():
	"""Create shopping services"""
	var general_shopping = Service.new("general_shopping", "General Shopping", ServiceType.SHOPPING)
	general_shopping.description = "Buy and sell general goods"
	general_shopping.location = "market_square"
	general_shopping.cost = 0
	general_shopping.benefits = {"inventory_access": true, "trade_opportunities": 1}
	services["general_shopping"] = general_shopping

	var luxury_goods = Service.new("luxury_goods", "Luxury Goods", ServiceType.SHOPPING)
	luxury_goods.description = "Purchase high-quality luxury items"
	luxury_goods.location = "noble_manor"
	luxury_goods.cost = 100
	luxury_goods.requirements = {"noble_reputation": 30}
	luxury_goods.benefits = {"luxury_items": true, "noble_connections": 1}
	services["luxury_goods"] = luxury_goods

func create_accommodation_services():
	"""Create accommodation services"""
	var accommodation = Service.new("accommodation", "Accommodation", ServiceType.ACCOMMODATION)
	accommodation.description = "Stay at a local inn or tavern"
	accommodation.location = "golden_harp"
	accommodation.cost = 2
	accommodation.benefits = {"rest": true, "safety": true, "social_opportunities": 1}
	services["accommodation"] = accommodation

func create_training_services():
	"""Create training services"""
	var combat_training = Service.new("combat_training", "Combat Training", ServiceType.TRAINING)
	combat_training.description = "Learn combat techniques from experienced guards"
	combat_training.location = "guard_barracks"
	combat_training.cost = 30
	combat_training.benefits = {"combat_skill": 5, "guard_reputation": 2}
	services["combat_training"] = combat_training

	var metalwork_training = Service.new("metalwork_training", "Metalwork Training", ServiceType.TRAINING)
	metalwork_training.description = "Learn metalworking from the master smith"
	metalwork_training.location = "smithy"
	metalwork_training.cost = 20
	metalwork_training.benefits = {"crafting_skill": 5, "smith_reputation": 2}
	services["metalwork_training"] = metalwork_training

func create_healing_services():
	"""Create healing services"""
	var healing = Service.new("healing", "Healing Services", ServiceType.HEALING)
	healing.description = "Receive magical or medical healing"
	healing.location = "temple"
	healing.cost = 10
	healing.benefits = {"hit_points": 10, "disease_cure": true}
	services["healing"] = healing

func create_information_services():
	"""Create information services"""
	var information_broker = Service.new("information_broker", "Information Broker", ServiceType.INFORMATION)
	information_broker.description = "Purchase valuable information"
	information_broker.location = "market_square"
	information_broker.cost = 10
	information_broker.benefits = {"gossip_knowledge": 1, "quest_hints": 1}
	services["information_broker"] = information_broker

func create_entertainment_services():
	"""Create entertainment services"""
	var entertainment = Service.new("entertainment", "Entertainment", ServiceType.ENTERTAINMENT)
	entertainment.description = "Enjoy music, stories, and socializing"
	entertainment.location = "golden_harp"
	entertainment.cost = 3
	entertainment.benefits = {"social_connections": 2, "charisma_exp": 5}
	services["entertainment"] = entertainment

func create_administration_services():
	"""Create administration services"""
	var legal_advice = Service.new("legal_advice", "Legal Advice", ServiceType.ADMINISTRATION)
	legal_advice.description = "Get legal counsel from town officials"
	legal_advice.location = "town_hall"
	legal_advice.cost = 20
	legal_advice.benefits = {"legal_knowledge": 1, "official_connections": 1}
	services["legal_advice"] = legal_advice

func setup_town_events():
	"""Initialize town events"""
	create_market_events()
	create_festival_events()
	create_emergency_events()
	create_visitor_events()
	create_trade_events()

func create_market_events():
	"""Create market-related events"""
	var market_day = TownEvent.new("market_day", "Market Day", TownEventType.MARKET_DAY)
	market_day.description = "A special market day with extra vendors and deals"
	market_day.duration_days = 1
	market_day.effects = {"shop_discounts": 0.2, "extra_vendors": 3}
	market_day.rewards = {"gold": 25, "trade_opportunities": 2}
	town_events["market_day"] = market_day

func create_festival_events():
	"""Create festival events"""
	var harvest_festival = TownEvent.new("harvest_festival", "Harvest Festival", TownEventType.FESTIVAL)
	harvest_festival.description = "A celebration of the harvest with food, music, and games"
	harvest_festival.duration_days = 3
	harvest_festival.effects = {"town_morale": 50, "visitor_increase": 100}
	harvest_festival.rewards = {"town_reputation": 15, "social_connections": 5, "gold": 50}
	town_events["harvest_festival"] = harvest_festival

func create_emergency_events():
	"""Create emergency events"""
	var crime_wave = TownEvent.new("crime_wave", "Crime Wave", TownEventType.CRIME_WAVE)
	crime_wave.description = "Increased criminal activity requires extra vigilance"
	crime_wave.duration_days = 7
	crime_wave.effects = {"security_increase": 25, "guard_patrols": 50}
	crime_wave.requirements = {"guard_reputation": 20}
	crime_wave.rewards = {"guard_reputation": 10, "combat_exp": 25}
	town_events["crime_wave"] = crime_wave

func create_visitor_events():
	"""Create visitor events"""
	var noble_visitor = TownEvent.new("noble_visitor", "Noble Visitor", TownEventType.VISITOR)
	noble_visitor.description = "An important noble visits the town"
	noble_visitor.duration_days = 2
	noble_visitor.effects = {"noble_attention": 100, "social_opportunities": 50}
	noble_visitor.requirements = {"noble_reputation": 30}
	noble_visitor.rewards = {"noble_reputation": 20, "political_connections": 3}
	town_events["noble_visitor"] = noble_visitor

func create_trade_events():
	"""Create trade events"""
	var trade_deal = TownEvent.new("trade_deal", "Trade Deal", TownEventType.TRADE_DEAL)
	trade_deal.description = "A lucrative trade opportunity presents itself"
	trade_deal.duration_days = 5
	trade_deal.effects = {"trade_increase": 75, "merchant_activity": 100}
	trade_deal.requirements = {"merchant_reputation": 25}
	trade_deal.rewards = {"gold": 200, "trade_connections": 5}
	town_events["trade_deal"] = trade_deal

func visit_location(character: Character, location_id: String) -> Dictionary:
	"""Handle character visiting a location"""
	var location = locations.get(location_id)
	if location == null:
		return {"success": false, "message": "Location not found"}

	# Check access requirements
	if not can_access_location(character, location):
		return {"success": false, "message": "You don't have access to this location"}

	# Check if location is open
	if not is_location_open(location):
		return {"success": false, "message": "This location is currently closed"}

	location_visited.emit(character, location_id)
	return {"success": true, "message": "You visit %s" % location.name, "location": location}

func can_access_location(character: Character, location: Location) -> bool:
	"""Check if character can access a location"""
	# Check reputation requirement
	if location.reputation_required > 0:
		var town_reputation = character.faction_reputation.get("Town", 0)
		if town_reputation < location.reputation_required:
			return false

	# Check other requirements
	for req_key in location.requirements.keys():
		var req_value = location.requirements[req_key]
		var char_value = character.get(req_key, 0)
		if char_value < req_value:
			return false

	return true

func is_location_open(location: Location) -> bool:
	"""Check if location is currently open"""
	var current_hour = Time.get_datetime_dict_from_system().hour
	var time_period = "morning" if current_hour < 12 else "afternoon" if current_hour < 18 else "evening"

	return location.hours.get(time_period, "closed") == "open"

func use_service(character: Character, service_id: String) -> Dictionary:
	"""Handle character using a service"""
	var service = services.get(service_id)
	if service == null:
		return {"success": false, "message": "Service not found"}

	# Check if character can afford the service
	if not character.spend_gold(service.cost):
		return {"success": false, "message": "You can't afford this service"}

	# Check requirements
	for req_key in service.requirements.keys():
		var req_value = service.requirements[req_key]
		var char_value = character.get(req_key)
		if char_value < req_value:
			return {"success": false, "message": "You don't meet the requirements for this service"}

	# Give benefits
	for benefit_type in service.benefits.keys():
		var benefit_amount = service.benefits[benefit_type]
		give_service_benefit(character, benefit_type, benefit_amount)

	service_used.emit(character, service_id, service.cost)
	return {"success": true, "message": "You use %s" % service.name, "service": service}

func give_service_benefit(character: Character, benefit_type: String, amount: int) -> void:
	"""Give a service benefit to a character"""
	match benefit_type:
		"hit_points":
			character.hit_points = min(character.max_hit_points, character.hit_points + amount)
		"charisma_exp":
			character.charisma_experience += amount
		"combat_skill", "crafting_skill":
			# Add to character's skill experience
			if not character.has_method("add_skill_exp"):
				character.set("skill_experience", character.get("skill_experience") + amount)
		"social_connections", "trade_opportunities", "gossip_knowledge", "quest_hints", "legal_knowledge", "official_connections", "noble_connections", "trade_connections", "political_connections":
			# Add to character's various connection/knowledge pools
			if not character.has_method("add_" + benefit_type):
				character.set(benefit_type, character.get(benefit_type) + amount)
		"guard_reputation", "smith_reputation":
			var faction_name = benefit_type.replace("_reputation", "")
			if faction_name == "guard":
				faction_name = "Town Guard"
			elif faction_name == "smith":
				faction_name = "Smith's Guild"

			if not character.faction_reputation.has(faction_name):
				character.faction_reputation[faction_name] = 0
			character.faction_reputation[faction_name] += amount

func get_available_locations(character: Character) -> Array[Location]:
	"""Get locations available to a character"""
	var available: Array[Location] = []

	for location in locations.values():
		if can_access_location(character, location) and is_location_open(location):
			available.append(location)

	return available

func get_available_services(character: Character, location_id: String = "") -> Array[Service]:
	"""Get services available to a character"""
	var available: Array[Service] = []

	for service in services.values():
		var can_use = true

		# Check location requirement
		if location_id != "" and service.location != location_id:
			can_use = false

		# Check requirements
		for req_key in service.requirements.keys():
			var req_value = service.requirements[req_key]
			var char_value = character.get(req_key)
			if char_value < req_value:
				can_use = false
				break

		# Check if character can afford it
		if character.gold < service.cost:
			can_use = false

		if can_use:
			available.append(service)

	return available

func trigger_town_event(event_id: String, character: Character) -> bool:
	"""Trigger a town event"""
	var event = town_events.get(event_id)
	if event == null:
		return false

	# Check requirements
	for req_key in event.requirements.keys():
		var req_value = event.requirements[req_key]
		var char_value = character.get(req_key)
		if char_value < req_value:
			return false

	# Give rewards
	for reward_type in event.rewards.keys():
		var reward_amount = event.rewards[reward_type]
		give_town_event_reward(character, reward_type, reward_amount)

	active_events.append(event_id)
	town_event_triggered.emit(event)
	return true

func give_town_event_reward(character: Character, reward_type: String, amount: int) -> void:
	"""Give a town event reward to a character"""
	match reward_type:
		"gold":
			character.add_gold(amount)
		"town_reputation", "noble_reputation", "guard_reputation", "smith_reputation", "merchant_reputation":
			var faction_name = reward_type.replace("_reputation", "")
			if faction_name == "town":
				faction_name = "Town"
			elif faction_name == "noble":
				faction_name = "Lord's Alliance"
			elif faction_name == "guard":
				faction_name = "Town Guard"
			elif faction_name == "smith":
				faction_name = "Smith's Guild"
			elif faction_name == "merchant":
				faction_name = "Merchant Guild"

			if not character.faction_reputation.has(faction_name):
				character.faction_reputation[faction_name] = 0
			character.faction_reputation[faction_name] += amount
		"social_connections", "trade_opportunities", "trade_connections", "political_connections":
			if not character.has_method("add_" + reward_type):
				character.set(reward_type, character.get(reward_type) + amount)
		"combat_exp":
			character.add_experience(amount)
