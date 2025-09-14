extends Node

# Town services system
# Handles service usage, benefits, and character interactions with town services

class_name TownServices

# Town data manager reference
var town_data_manager: TownDataManager

func _init():
	town_data_manager = TownDataManager.new()

# Use a service
func use_service(character: Character, service_id: String) -> Dictionary:
	"""Use a town service and return results"""
	var service = town_data_manager.get_service(service_id)
	if service == null:
		return {"success": false, "message": "Service not found"}

	# Check if character can afford the service
	if character.gold < service.cost:
		return {"success": false, "message": "Not enough gold"}

	# Check requirements
	if not meets_service_requirements(character, service):
		return {"success": false, "message": "Requirements not met"}

	# Deduct cost
	character.gold -= service.cost

	# Give benefits
	give_service_benefits(character, service)

	return {"success": true, "message": "Service used successfully", "cost": service.cost}

# Check if character meets service requirements
func meets_service_requirements(character: Character, service: Service) -> bool:
	"""Check if character meets service requirements"""
	var requirements = service.requirements

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

# Give service benefits to character
func give_service_benefits(character: Character, service: Service) -> void:
	"""Give all benefits from a service to a character"""
	var benefits = service.benefits

	for benefit_type in benefits:
		give_service_benefit(character, benefit_type, 1)

# Give a specific service benefit
func give_service_benefit(character: Character, benefit_type: String, amount: int) -> void:
	"""Give a specific type of service benefit to a character"""
	match benefit_type:
		"healing":
			give_healing_benefit(character, amount)
		"rest":
			give_rest_benefit(character, amount)
		"training":
			give_training_benefit(character, amount)
		"information":
			give_information_benefit(character, amount)
		"storage":
			give_storage_benefit(character, amount)
		"transportation":
			give_transportation_benefit(character, amount)
		"entertainment":
			give_entertainment_benefit(character, amount)
		"administration":
			give_administration_benefit(character, amount)
		_:
			print("Unknown service benefit type: " + benefit_type)

# Give healing benefit
func give_healing_benefit(character: Character, amount: int) -> void:
	"""Give healing to character"""
	var healing_amount = min(amount, character.max_hit_points - character.hit_points)
	character.hit_points += healing_amount
	print("Received " + str(healing_amount) + " points of healing")

# Give rest benefit
func give_rest_benefit(character: Character, amount: int) -> void:
	"""Give rest benefits to character"""
	# Restore hit points
	var rest_healing = min(amount, character.max_hit_points - character.hit_points)
	character.hit_points += rest_healing

	# Remove exhaustion levels
	for i in range(character.active_buffs.size()):
		var buff = character.active_buffs[i]
		if buff.has("name") and buff["name"] == "exhaustion":
			var exhaustion_level = buff.get("level", 0)
			if exhaustion_level > 0:
				character.active_buffs[i]["level"] = max(0, exhaustion_level - 1)
			break

	print("Rested and recovered " + str(rest_healing) + " hit points")

# Give training benefit
func give_training_benefit(character: Character, amount: int) -> void:
	"""Give training benefits to character"""
	# This would give experience or skill improvements
	character.experience += amount
	print("Gained " + str(amount) + " experience from training")

# Give information benefit
func give_information_benefit(_character: Character, _amount: int) -> void:
	"""Give information benefits to character"""
	# This would unlock quests, locations, or other information
	print("Received valuable information")

# Give storage benefit
func give_storage_benefit(_character: Character, _amount: int) -> void:
	"""Give storage benefits to character"""
	# This would provide item storage space
	print("Access to storage facility granted")

# Give transportation benefit
func give_transportation_benefit(_character: Character, _amount: int) -> void:
	"""Give transportation benefits to character"""
	# This would enable travel to other locations
	print("Transportation arranged")

# Give entertainment benefit
func give_entertainment_benefit(_character: Character, _amount: int) -> void:
	"""Give entertainment benefits to character"""
	# This would provide morale or other benefits
	print("Enjoyed entertainment and improved morale")

# Give administration benefit
func give_administration_benefit(_character: Character, _amount: int) -> void:
	"""Give administration benefits to character"""
	# This would provide official services
	print("Administrative services completed")

# Get available services for character
func get_available_services(character: Character, location_id: String = "") -> Array[Service]:
	"""Get services available to a character"""
	var available_services: Array[Service] = []
	var all_services = town_data_manager.get_all_services()

	for service in all_services.values():
		# Filter by location if specified
		if location_id != "" and service.location_id != location_id:
			continue

		# Check if character meets requirements
		if meets_service_requirements(character, service):
			available_services.append(service)

	return available_services

# Get services by type
func get_services_by_type(character: Character, service_type: ServiceType) -> Array[Service]:
	"""Get services of a specific type available to a character"""
	var available_services: Array[Service] = []
	var services_by_type = town_data_manager.get_services_by_type(service_type)

	for service in services_by_type:
		if meets_service_requirements(character, service):
			available_services.append(service)

	return available_services

# Get service cost
func get_service_cost(service_id: String) -> int:
	"""Get the cost of a service"""
	var service = town_data_manager.get_service(service_id)
	if service:
		return service.cost
	return 0

# Check if character can afford service
func can_afford_service(character: Character, service_id: String) -> bool:
	"""Check if character can afford a service"""
	var service = town_data_manager.get_service(service_id)
	if service:
		return character.gold >= service.cost
	return false

# Get service description
func get_service_description(service_id: String) -> String:
	"""Get description of a service"""
	var service = town_data_manager.get_service(service_id)
	if service:
		return service.description
	return "Service not found"

# Get service requirements text
func get_service_requirements_text(service_id: String) -> String:
	"""Get human-readable requirements text for a service"""
	var service = town_data_manager.get_service(service_id)
	if not service:
		return "Service not found"

	var requirements = service.requirements
	var requirements_text = ""

	if requirements.has("level"):
		requirements_text += "Level " + str(requirements["level"]) + " required\n"

	if requirements.has("gold"):
		requirements_text += str(requirements["gold"]) + " gold required\n"

	if requirements.has("skills"):
		var skills = requirements["skills"]
		if skills is Array:
			requirements_text += "Skills required: " + ", ".join(skills) + "\n"

	if requirements.has("reputation"):
		var reputation = requirements["reputation"]
		if reputation is Dictionary:
			for faction in reputation:
				requirements_text += str(reputation[faction]) + " " + faction + " reputation required\n"

	return requirements_text

# Get service benefits text
func get_service_benefits_text(service_id: String) -> String:
	"""Get human-readable benefits text for a service"""
	var service = town_data_manager.get_service(service_id)
	if not service:
		return "Service not found"

	var benefits = service.benefits
	var benefits_text = ""

	for benefit_type in benefits:
		var benefit_value = benefits[benefit_type]
		match benefit_type:
			"healing":
				benefits_text += "Heals " + str(benefit_value) + " hit points\n"
			"rest":
				benefits_text += "Provides rest benefits\n"
			"training":
				benefits_text += "Grants " + str(benefit_value) + " experience\n"
			"information":
				benefits_text += "Provides valuable information\n"
			"storage":
				benefits_text += "Access to storage facility\n"
			"transportation":
				benefits_text += "Transportation services\n"
			"entertainment":
				benefits_text += "Entertainment and morale boost\n"
			"administration":
				benefits_text += "Administrative services\n"
			_:
				benefits_text += benefit_type + ": " + str(benefit_value) + "\n"

	return benefits_text

# Get town data manager
func get_town_data_manager() -> TownDataManager:
	"""Get the town data manager instance"""
	return town_data_manager
