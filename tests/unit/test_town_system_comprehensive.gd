extends GutTest

# Comprehensive test for TownSystem
class_name TestTownSystemComprehensive

var town_system: TownSystem
var test_character: Character

func before_each():
	town_system = TownSystem.new()
	test_character = Character.new()
	test_character.name = "TestCharacter"
	test_character.level = 5
	test_character.gold = 1000

func test_town_system_creation():
	"""Test that TownSystem can be created"""
	assert_not_null(town_system, "TownSystem should be created")
	assert_true(town_system is TownSystem, "Should be a TownSystem instance")

func test_create_town():
	"""Test creating a new town"""
	var town_data = {
		"id": "test_town_001",
		"name": "Test Town",
		"description": "A test town for unit testing",
		"size": "small",
		"population": 500,
		"prosperity": "moderate",
		"locations": [
			{
				"id": "inn_001",
				"name": "The Test Inn",
				"type": "inn",
				"services": ["lodging", "food", "drink"]
			},
			{
				"id": "shop_001",
				"name": "Test General Store",
				"type": "shop",
				"services": ["buy", "sell", "repair"]
			}
		]
	}

	var town = town_system.create_town(town_data)

	assert_not_null(town, "Town should be created")
	assert_eq(town["id"], "test_town_001")
	assert_eq(town["name"], "Test Town")
	assert_eq(town["size"], "small")

func test_town_locations():
	"""Test town location system"""
	var town_data = {
		"id": "location_test_001",
		"name": "Location Test Town",
		"locations": [
			{
				"id": "tavern_001",
				"name": "The Test Tavern",
				"type": "tavern",
				"services": ["food", "drink", "gossip"]
			},
			{
				"id": "blacksmith_001",
				"name": "Test Blacksmith",
				"type": "blacksmith",
				"services": ["repair", "craft", "buy_weapons"]
			}
		]
	}

	var town = town_system.create_town(town_data)
	var locations = town_system.get_town_locations(town["id"])

	assert_eq(locations.size(), 2, "Should have 2 locations")
	assert_true(town_system.has_location(town["id"], "tavern_001"), "Should have tavern location")
	assert_true(town_system.has_location(town["id"], "blacksmith_001"), "Should have blacksmith location")

func test_town_services():
	"""Test town service system"""
	var town_data = {
		"id": "service_test_001",
		"name": "Service Test Town",
		"locations": [
			{
				"id": "inn_001",
				"name": "Test Inn",
				"type": "inn",
				"services": ["lodging", "food", "stables"]
			}
		]
	}

	var town = town_system.create_town(town_data)
	var services = town_system.get_location_services(town["id"], "inn_001")

	assert_true(services.has("lodging"), "Should have lodging service")
	assert_true(services.has("food"), "Should have food service")
	assert_true(services.has("stables"), "Should have stables service")

func test_town_events():
	"""Test town event system"""
	var town_data = {
		"id": "event_test_001",
		"name": "Event Test Town",
		"events": [
			{
				"id": "festival_001",
				"name": "Test Festival",
				"type": "celebration",
				"frequency": "annual",
				"effects": {
					"prosperity": 10,
					"population_happiness": 15
				}
			},
			{
				"id": "disaster_001",
				"name": "Test Disaster",
				"type": "disaster",
				"frequency": "rare",
				"effects": {
					"prosperity": -20,
					"population": -50
				}
			}
		]
	}

	var town = town_system.create_town(town_data)
	var events = town_system.get_town_events(town["id"])

	assert_eq(events.size(), 2, "Should have 2 events")

	# Test event triggering
	var festival_event = town_system.get_event(town["id"], "festival_001")
	var result = town_system.trigger_event(town["id"], festival_event)

	assert_true(result["success"], "Should successfully trigger event")
	assert_eq(town["prosperity"], 10, "Town prosperity should increase")

func test_town_economy():
	"""Test town economy system"""
	var town_data = {
		"id": "economy_test_001",
		"name": "Economy Test Town",
		"prosperity": "moderate",
		"trade_goods": ["grain", "cloth", "tools"],
		"prices": {
			"grain": 2,
			"cloth": 5,
			"tools": 15
		}
	}

	var town = town_system.create_town(town_data)

	# Test buying goods
	var buy_result = town_system.buy_goods(test_character, town["id"], "grain", 10)
	assert_true(buy_result["success"], "Should successfully buy goods")
	assert_eq(test_character.gold, 1000 - 20, "Character gold should decrease")

	# Test selling goods
	var sell_result = town_system.sell_goods(test_character, town["id"], "grain", 5)
	assert_true(sell_result["success"], "Should successfully sell goods")
	assert_eq(test_character.gold, 980 + 10, "Character gold should increase")

func test_town_population():
	"""Test town population system"""
	var town_data = {
		"id": "population_test_001",
		"name": "Population Test Town",
		"population": 1000,
		"growth_rate": 0.02,
		"capacity": 2000
	}

	var town = town_system.create_town(town_data)

	# Test population growth
	town_system.process_population_growth(town["id"], 30)  # 30 days

	var new_population = town["population"]
	assert_gt(new_population, 1000, "Population should grow over time")
	assert_le(new_population, 2000, "Population should not exceed capacity")

func test_town_prosperity():
	"""Test town prosperity system"""
	var town_data = {
		"id": "prosperity_test_001",
		"name": "Prosperity Test Town",
		"prosperity": "poor",
		"prosperity_factors": {
			"trade": 0.3,
			"security": 0.2,
			"infrastructure": 0.5
		}
	}

	var town = town_system.create_town(town_data)

	# Test prosperity changes
	town_system.update_prosperity(town["id"], {"trade": 0.8, "security": 0.9, "infrastructure": 0.7})

	var prosperity_level = town_system.get_prosperity_level(town["id"])
	assert_ne(prosperity_level, "poor", "Prosperity should improve")

func test_town_security():
	"""Test town security system"""
	var town_data = {
		"id": "security_test_001",
		"name": "Security Test Town",
		"security_level": "moderate",
		"guards": 20,
		"crime_rate": 0.1
	}

	var town = town_system.create_town(town_data)

	# Test security events
	var crime_event = {
		"id": "crime_001",
		"type": "theft",
		"severity": "minor",
		"effects": {"crime_rate": 0.05}
	}

	town_system.handle_security_event(town["id"], crime_event)

	var new_crime_rate = town["crime_rate"]
	assert_gt(new_crime_rate, 0.1, "Crime rate should increase")

func test_town_factions():
	"""Test town faction system"""
	var town_data = {
		"id": "faction_test_001",
		"name": "Faction Test Town",
		"factions": [
			{
				"id": "merchants_guild",
				"name": "Merchants Guild",
				"influence": 0.6,
				"goals": ["increase_trade", "lower_taxes"]
			},
			{
				"id": "thieves_guild",
				"name": "Thieves Guild",
				"influence": 0.3,
				"goals": ["reduce_security", "increase_crime"]
			}
		]
	}

	var town = town_system.create_town(town_data)
	var factions = town_system.get_town_factions(town["id"])

	assert_eq(factions.size(), 2, "Should have 2 factions")

	# Test faction influence
	var merchant_influence = town_system.get_faction_influence(town["id"], "merchants_guild")
	assert_eq(merchant_influence, 0.6, "Should have correct merchant influence")

func test_town_services_integration():
	"""Test town services integration with character systems"""
	var town_data = {
		"id": "integration_test_001",
		"name": "Integration Test Town",
		"locations": [
			{
				"id": "inn_001",
				"name": "Test Inn",
				"type": "inn",
				"services": ["lodging", "food"],
				"prices": {"lodging": 5, "food": 2}
			}
		]
	}

	var town = town_system.create_town(town_data)

	# Test lodging service
	var lodging_result = town_system.use_service(test_character, town["id"], "inn_001", "lodging")
	assert_true(lodging_result["success"], "Should successfully use lodging service")
	assert_eq(test_character.gold, 1000 - 5, "Character should pay for lodging")

	# Test food service
	var food_result = town_system.use_service(test_character, town["id"], "inn_001", "food")
	assert_true(food_result["success"], "Should successfully use food service")
	assert_eq(test_character.gold, 995 - 2, "Character should pay for food")

func test_town_travel():
	"""Test town travel and distance system"""
	var town1_data = {
		"id": "town_001",
		"name": "Town One",
		"location": {"x": 0, "y": 0}
	}

	var town2_data = {
		"id": "town_002",
		"name": "Town Two",
		"location": {"x": 100, "y": 100}
	}

	var town1 = town_system.create_town(town1_data)
	var town2 = town_system.create_town(town2_data)

	var distance = town_system.calculate_distance(town1["id"], town2["id"])
	assert_gt(distance, 0, "Distance should be greater than 0")

	var travel_time = town_system.calculate_travel_time(test_character, town1["id"], town2["id"])
	assert_gt(travel_time, 0, "Travel time should be greater than 0")

func test_town_system_integration():
	"""Test integration with other game systems"""
	var town_data = {
		"id": "system_integration_001",
		"name": "System Integration Town",
		"locations": [
			{
				"id": "shop_001",
				"name": "Test Shop",
				"type": "shop",
				"services": ["buy", "sell"]
			}
		]
	}

	var town = town_system.create_town(town_data)

	# Test with equipment system
	var equipment_system = EquipmentSystem.new()
	var shop_items = town_system.get_shop_items(town["id"], "shop_001")
	assert_gt(shop_items.size(), 0, "Shop should have items")

	# Test with faction system
	var faction_system = FactionSystem.new()
	faction_system.add_reputation(test_character, "merchants_guild", 50)

	var faction_services = town_system.get_faction_services(test_character, town["id"])
	assert_gt(faction_services.size(), 0, "Should have faction-specific services")
