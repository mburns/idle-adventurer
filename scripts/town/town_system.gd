extends Node

# Town system core - coordinates town data management, services, and events
# Simplified version that delegates to specialized modules

class_name TownSystem

# Module instances
var town_data_manager: TownDataManager
var town_services: TownServices
var town_events: TownEvents

# Signals
signal location_visited(character: Character, location: String)
signal service_used(character: Character, service: String, cost: int)
signal town_event_triggered(event: TownEvent)

func _init():
	# Initialize modules
	town_data_manager = TownDataManager.new()
	town_services = TownServices.new()
	town_events = TownEvents.new()

func _ready():
	# Load town data
	town_data_manager.load_town_data()

# Visit a location
func visit_location(character: Character, location_id: String) -> Dictionary:
	"""Visit a town location and return results"""
	var location = town_data_manager.get_location(location_id)
	if location == null:
		return {"success": false, "message": "Location not found"}

	# Check if character can access the location
	if not can_access_location(character, location):
		return {"success": false, "message": "Cannot access location"}

	# Check if location is open
	if not is_location_open(location):
		return {"success": false, "message": "Location is closed"}

	# Emit signal
	location_visited.emit(character, location_id)

	return {"success": true, "message": "Visited " + location.name, "location": location}

# Use a service
func use_service(character: Character, service_id: String) -> Dictionary:
	"""Use a town service and return results"""
	var result = town_services.use_service(character, service_id)

	if result["success"]:
		service_used.emit(character, service_id, result.get("cost", 0))

	return result

# Trigger a town event
func trigger_town_event(event_id: String, character: Character) -> bool:
	"""Trigger a town event for a character"""
	var success = town_events.trigger_town_event(event_id, character)

	if success:
		var event = town_data_manager.get_event(event_id)
		if event:
			town_event_triggered.emit(event)

	return success

# Check if character can access a location
func can_access_location(character: Character, location: Location) -> bool:
	"""Check if character can access a location"""
	var requirements = location.requirements

	# Check level requirement
	if requirements.has("level"):
		if character.level < requirements["level"]:
			return false

	# Check gold requirement
	if requirements.has("gold"):
		if character.gold < requirements["gold"]:
			return false

	# Check item requirements
	if requirements.has("items"):
		var required_items = requirements["items"]
		if required_items is Array:
			for item in required_items:
				# This would check if character has the item
				# For now, just return true
				pass

	# Check skill requirements
	if requirements.has("skills"):
		var required_skills = requirements["skills"]
		if required_skills is Array:
			for skill in required_skills:
				if skill not in character.skill_proficiencies:
					return false

	# Check reputation requirements
	if requirements.has("reputation"):
		var reputation_reqs = requirements["reputation"]
		if reputation_reqs is Dictionary:
			for faction in reputation_reqs:
				var required_rep = reputation_reqs[faction]
				var current_rep = character.faction_reputation.get(faction, 0)
				if current_rep < required_rep:
					return false

	return true

# Check if location is open
func is_location_open(location: Location) -> bool:
	"""Check if a location is currently open"""
	var current_hour = Time.get_datetime_dict_from_system()["hour"]
	var hours = location.hours

	if hours.has("open") and hours.has("close"):
		var open_hour = hours["open"]
		var close_hour = hours["close"]

		if close_hour > open_hour:
			# Normal hours (e.g., 6 AM to 10 PM)
			return current_hour >= open_hour and current_hour < close_hour
		else:
			# Overnight hours (e.g., 10 PM to 6 AM)
			return current_hour >= open_hour or current_hour < close_hour

	return true  # Always open if no hours specified

# Get available locations for character
func get_available_locations(character: Character) -> Array[Location]:
	"""Get locations available to a character"""
	var available_locations: Array[Location] = []
	var all_locations = town_data_manager.get_all_locations()

	for location in all_locations.values():
		if can_access_location(character, location):
			available_locations.append(location)

	return available_locations

# Get available services for character
func get_available_services(character: Character, location_id: String = "") -> Array[Service]:
	"""Get services available to a character"""
	return town_services.get_available_services(character, location_id)

# Get available events for character
func get_available_events(character: Character) -> Array[TownEvent]:
	"""Get events available to a character"""
	return town_events.get_available_events(character)

# Get location by ID
func get_location(location_id: String) -> Location:
	"""Get location by ID"""
	return town_data_manager.get_location(location_id)

# Get service by ID
func get_service(service_id: String) -> Service:
	"""Get service by ID"""
	return town_data_manager.get_service(service_id)

# Get event by ID
func get_event(event_id: String) -> TownEvent:
	"""Get event by ID"""
	return town_data_manager.get_event(event_id)

# Get all locations
func get_all_locations() -> Dictionary:
	"""Get all locations"""
	return town_data_manager.get_all_locations()

# Get all services
func get_all_services() -> Dictionary:
	"""Get all services"""
	return town_data_manager.get_all_services()

# Get all events
func get_all_events() -> Dictionary:
	"""Get all events"""
	return town_data_manager.get_all_events()

# Get locations by type
func get_locations_by_type(location_type: LocationType) -> Array[Location]:
	"""Get locations filtered by type"""
	return town_data_manager.get_locations_by_type(location_type)

# Get services by type
func get_services_by_type(service_type: ServiceType) -> Array[Service]:
	"""Get services filtered by type"""
	return town_data_manager.get_services_by_type(service_type)

# Get services for location
func get_services_for_location(location_id: String) -> Array[Service]:
	"""Get services available at a specific location"""
	return town_data_manager.get_services_for_location(location_id)

# Reload town data
func reload_town_data() -> void:
	"""Reload all town data from files"""
	town_data_manager.reload_town_data()

# Get town data manager (for advanced usage)
func get_town_data_manager() -> TownDataManager:
	"""Get the town data manager instance"""
	return town_data_manager

# Get town services (for advanced usage)
func get_town_services() -> TownServices:
	"""Get the town services instance"""
	return town_services

# Get town events (for advanced usage)
func get_town_events() -> TownEvents:
	"""Get the town events instance"""
	return town_events
