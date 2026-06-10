extends Node

# Town data management system
# Handles loading and managing town locations, services, and events from YAML files

class_name TownDataManager

# Data storage
var locations: Dictionary = {} # location_id -> Location
var services: Dictionary = {} # service_id -> Service
var events: Dictionary = {} # event_id -> TownEvent

func _init():
	pass

# Load all town data
func load_town_data() -> void:
	"""Load all town data from resource files"""
	load_locations_from_resources()
	load_services_from_resources()
	load_events_from_resources()
	print("Loaded " + str(locations.size()) + " locations, " + str(services.size()) + " services, " + str(events.size()) + " events")

# Load locations from resources
func load_locations_from_resources() -> void:
	"""Load town locations from resource file"""
	var resource_path = "res://data/towns/locations.tres"
	var resource = load(resource_path)
	if resource == null:
		print("Warning: Could not load locations from " + resource_path)
		return

	var resource_data = resource.get("metadata/yaml_data")
	if resource_data == null:
		resource_data = {}
	var locations_list = resource_data.get("locations", [])
	if locations_list.is_empty():
		print("Warning: No locations data found in " + resource_path)
		return
	for location_data in locations_list:
		var location_id = location_data.get("id", "")
		if location_id != "":
			var location = create_location_from_data(location_id, location_data)
			locations[location_id] = location

	print("Loaded " + str(locations_list.size()) + " locations")

# Load services from resources
func load_services_from_resources() -> void:
	"""Load town services from resource file"""
	var resource_path = "res://data/towns/services.tres"
	var resource = load(resource_path)
	if resource == null:
		print("Warning: Could not load services from " + resource_path)
		return

	var resource_data = resource.get("metadata/yaml_data")
	if resource_data == null:
		resource_data = {}
	var services_list = resource_data.get("services", [])
	if services_list.is_empty():
		print("Warning: No services data found in " + resource_path)
		return
	for service_data in services_list:
		var service_id = service_data.get("id", "")
		if service_id != "":
			var service = create_service_from_data(service_id, service_data)
			services[service_id] = service

	print("Loaded " + str(services_list.size()) + " services")

# Load events from resources
func load_events_from_resources() -> void:
	"""Load town events from resource file"""
	var resource_path = "res://data/towns/events.tres"
	var resource = load(resource_path)
	if resource == null:
		print("Warning: Could not load events from " + resource_path)
		return

	var resource_data = resource.get("metadata/yaml_data")
	if resource_data == null:
		resource_data = {}
	var events_list = resource_data.get("events", [])
	if events_list.is_empty():
		print("Warning: No events data found in " + resource_path)
		return
	for event_data in events_list:
		var event_id = event_data.get("id", "")
		if event_id != "":
			var event = create_event_from_data(event_id, event_data)
			events[event_id] = event

	print("Loaded " + str(events_list.size()) + " events")

# Create location from data
func create_location_from_data(location_id: String, data: Dictionary) -> Location:
	"""Create a Location object from data"""
	var location = Location.new()
	location.id = location_id
	location.name = data.get("name", "")
	location.description = data.get("description", "")
	location.location_type = get_location_type_from_string(data.get("type", "MARKET"))
	location.cost = data.get("cost", 0)
	location.requirements = data.get("requirements", {})
	location.hours = data.get("hours", {"open": 6, "close": 22})
	location.services = data.get("services", [])
	location.events = data.get("events", [])
	return location

# Create service from data
func create_service_from_data(service_id: String, data: Dictionary) -> Service:
	"""Create a Service object from data"""
	var service = Service.new()
	service.id = service_id
	service.name = data.get("name", "")
	service.description = data.get("description", "")
	service.service_type = get_service_type_from_string(data.get("type", "SHOPPING"))
	service.cost = data.get("cost", 0)
	service.requirements = data.get("requirements", {})
	service.benefits = data.get("benefits", {})
	service.location_id = data.get("location_id", "")
	return service

# Create event from data
func create_event_from_data(event_id: String, data: Dictionary) -> TownEvent:
	"""Create a TownEvent object from data"""
	var event = TownEvent.new()
	event.id = event_id
	event.name = data.get("name", "")
	event.description = data.get("description", "")
	event.event_type = get_event_type_from_string(data.get("type", "MARKET_DAY"))
	event.requirements = data.get("requirements", {})
	event.rewards = data.get("rewards", {})
	event.duration = data.get("duration", 3600)
	event.location_id = data.get("location_id", "")
	return event

# Get location type from string
func get_location_type_from_string(type_str: String) -> LocationType.Type:
	"""Convert string to LocationType enum"""
	match type_str.to_upper():
		"MARKET":
			return LocationType.Type.MARKET
		"TAVERN":
			return LocationType.Type.TAVERN
		"GUILD_HALL":
			return LocationType.Type.GUILD_HALL
		"TEMPLE":
			return LocationType.Type.TEMPLE
		"LIBRARY":
			return LocationType.Type.LIBRARY
		"SMITHY":
			return LocationType.Type.SMITHY
		"TOWN_HALL":
			return LocationType.Type.TOWN_HALL
		"GUARD_BARRACKS":
			return LocationType.Type.GUARD_BARRACKS
		"NOBLE_DISTRICT":
			return LocationType.Type.NOBLE_DISTRICT
		"RESIDENTIAL":
			return LocationType.Type.RESIDENTIAL
		"WAREHOUSE":
			return LocationType.Type.WAREHOUSE
		"STABLE":
			return LocationType.Type.STABLE
		_:
			return LocationType.Type.MARKET

# Get service type from string
func get_service_type_from_string(type_str: String) -> ServiceType.Type:
	"""Convert string to ServiceType enum"""
	match type_str.to_upper():
		"SHOPPING":
			return ServiceType.Type.SHOPPING
		"ACCOMMODATION":
			return ServiceType.Type.ACCOMMODATION
		"TRAINING":
			return ServiceType.Type.TRAINING
		"HEALING":
			return ServiceType.Type.HEALING
		"INFORMATION":
			return ServiceType.Type.INFORMATION
		"TRANSPORTATION":
			return ServiceType.Type.TRANSPORTATION
		"STORAGE":
			return ServiceType.Type.STORAGE
		"COMMUNICATION":
			return ServiceType.Type.COMMUNICATION
		"ENTERTAINMENT":
			return ServiceType.Type.ENTERTAINMENT
		"ADMINISTRATION":
			return ServiceType.Type.ADMINISTRATION
		_:
			return ServiceType.Type.SHOPPING

# Get event type from string
func get_event_type_from_string(type_str: String) -> TownEventType.Type:
	"""Convert string to TownEventType enum"""
	match type_str.to_upper():
		"MARKET_DAY":
			return TownEventType.Type.MARKET_DAY
		"FESTIVAL":
			return TownEventType.Type.FESTIVAL
		"EMERGENCY":
			return TownEventType.Type.EMERGENCY
		"VISITOR":
			return TownEventType.Type.VISITOR
		"CONSTRUCTION":
			return TownEventType.Type.CONSTRUCTION
		"TRADE_DEAL":
			return TownEventType.Type.TRADE_DEAL
		"CRIME_WAVE":
			return TownEventType.Type.CRIME_WAVE
		"WEATHER_EVENT":
			return TownEventType.Type.WEATHER_EVENT
		"POLITICAL_EVENT":
			return TownEventType.Type.POLITICAL_EVENT
		"RELIGIOUS_EVENT":
			return TownEventType.Type.RELIGIOUS_EVENT
		"MILITARY_EVENT":
			return TownEventType.Type.MILITARY_EVENT
		_:
			return TownEventType.Type.MARKET_DAY

# Get location by ID
func get_location(location_id: String) -> Location:
	"""Get location by ID"""
	return locations.get(location_id, null)

# Get service by ID
func get_service(service_id: String) -> Service:
	"""Get service by ID"""
	return services.get(service_id, null)

# Get event by ID
func get_event(event_id: String) -> TownEvent:
	"""Get event by ID"""
	return events.get(event_id, null)

# Get all locations
func get_all_locations() -> Dictionary:
	"""Get all locations"""
	return locations.duplicate()

# Get all services
func get_all_services() -> Dictionary:
	"""Get all services"""
	return services.duplicate()

# Get all events
func get_all_events() -> Dictionary:
	"""Get all events"""
	return events.duplicate()

# Get locations by type
func get_locations_by_type(location_type: LocationType) -> Array[Location]:
	"""Get locations filtered by type"""
	var filtered_locations: Array[Location] = []
	for location in locations.values():
		if location.location_type == location_type:
			filtered_locations.append(location)
	return filtered_locations

# Get services by type
func get_services_by_type(service_type: ServiceType) -> Array[Service]:
	"""Get services filtered by type"""
	var filtered_services: Array[Service] = []
	for service in services.values():
		if service.service_type == service_type:
			filtered_services.append(service)
	return filtered_services

# Get services for location
func get_services_for_location(location_id: String) -> Array[Service]:
	"""Get services available at a specific location"""
	var location_services: Array[Service] = []
	for service in services.values():
		if service.location_id == location_id:
			location_services.append(service)
	return location_services

# Reload town data
func reload_town_data() -> void:
	"""Reload all town data from files"""
	locations.clear()
	services.clear()
	events.clear()
	load_town_data()

# Validate location data
func validate_location_data(location_data: Dictionary) -> bool:
	"""Validate location data structure"""
	var required_fields = ["id", "name", "type"]

	for field in required_fields:
		if not location_data.has(field) or location_data[field].is_empty():
			print("Invalid location data: missing " + field)
			return false

	return true

# Validate service data
func validate_service_data(service_data: Dictionary) -> bool:
	"""Validate service data structure"""
	var required_fields = ["id", "name", "type"]

	for field in required_fields:
		if not service_data.has(field) or service_data[field].is_empty():
			print("Invalid service data: missing " + field)
			return false

	return true

# Validate event data
func validate_event_data(event_data: Dictionary) -> bool:
	"""Validate event data structure"""
	var required_fields = ["id", "name", "type"]

	for field in required_fields:
		if not event_data.has(field) or event_data[field].is_empty():
			print("Invalid event data: missing " + field)
			return false

	return true
