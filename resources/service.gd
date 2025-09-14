class_name Service
extends Resource

# Services available in towns and locations

# Use global ServiceType enum from service_type.gd

@export var service_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var service_type: ServiceType.Type = ServiceType.Type.ACCOMMODATION
@export var location_id: String = ""
@export var provider_npc: String = ""  # NPC ID providing the service
@export var cost: Dictionary = {}  # Cost structure
@export var requirements: Dictionary = {}  # Service requirements
@export var duration: int = 1  # Duration in hours
@export var availability: String = "always"  # always, daytime, nighttime, specific_hours
@export var capacity: int = 1  # How many people can use service simultaneously
@export var current_users: int = 0
@export var quality: String = "average"  # poor, average, good, excellent, legendary
@export var reputation_required: Dictionary = {}  # Reputation requirements
@export var level_required: int = 1
@export var gold_required: int = 0
@export var items_required: Array[String] = []  # Items needed for service
@export var outcomes: Dictionary = {}  # Possible outcomes
@export var modifiers: Dictionary = {}  # Quality/cost modifiers
@export var restrictions: Dictionary = {}  # Service restrictions
@export var benefits: Array[String] = []  # Benefits provided
@export var risks: Array[String] = []  # Risks involved
@export var alternatives: Array[String] = []  # Alternative service IDs

func get_service_type_string() -> String:
	"""Get service type as string"""
	match service_type:
		ServiceType.Type.ACCOMMODATION:
			return "Accommodation"
		ServiceType.Type.FOOD_DRINK:
			return "Food & Drink"
		ServiceType.Type.SHOPPING:
			return "Shopping"
		ServiceType.Type.REPAIR:
			return "Repair"
		ServiceType.Type.UPGRADE:
			return "Upgrade"
		ServiceType.Type.TRAINING:
			return "Training"
		ServiceType.Type.HEALING:
			return "Healing"
		ServiceType.Type.TRANSPORTATION:
			return "Transportation"
		ServiceType.Type.INFORMATION:
			return "Information"
		ServiceType.Type.QUEST:
			return "Quest"
		ServiceType.Type.BANKING:
			return "Banking"
		ServiceType.Type.STORAGE:
			return "Storage"
		ServiceType.Type.ENTERTAINMENT:
			return "Entertainment"
		ServiceType.Type.SECURITY:
			return "Security"
		ServiceType.Type.COMMUNICATION:
			return "Communication"
		ServiceType.Type.RESEARCH:
			return "Research"
		ServiceType.Type.MANUFACTURING:
			return "Manufacturing"
		ServiceType.Type.FARMING:
			return "Farming"
		ServiceType.Type.MINING:
			return "Mining"
		ServiceType.Type.FORESTRY:
			return "Forestry"
		ServiceType.Type.FISHING:
			return "Fishing"
		ServiceType.Type.HUNTING:
			return "Hunting"
		ServiceType.Type.TRADING:
			return "Trading"
		ServiceType.Type.SMUGGLING:
			return "Smuggling"
		ServiceType.Type.ESPIONAGE:
			return "Espionage"
		ServiceType.Type.ASSASSINATION:
			return "Assassination"
		ServiceType.Type.PROTECTION:
			return "Protection"
		ServiceType.Type.MEDIATION:
			return "Mediation"
		ServiceType.Type.ARBITRATION:
			return "Arbitration"
		ServiceType.Type.LEGAL:
			return "Legal"
		ServiceType.Type.MEDICAL:
			return "Medical"
		ServiceType.Type.SPIRITUAL:
			return "Spiritual"
		ServiceType.Type.EDUCATIONAL:
			return "Educational"
		ServiceType.Type.RECREATIONAL:
			return "Recreational"
		ServiceType.Type.SOCIAL:
			return "Social"
		ServiceType.Type.POLITICAL:
			return "Political"
		ServiceType.Type.MILITARY:
			return "Military"
		ServiceType.Type.RELIGIOUS:
			return "Religious"
		ServiceType.Type.MAGICAL:
			return "Magical"
		ServiceType.Type.ALCHEMICAL:
			return "Alchemical"
		ServiceType.Type.ENCHANTMENT:
			return "Enchantment"
		ServiceType.Type.DIVINATION:
			return "Divination"
		ServiceType.Type.SUMMONING:
			return "Summoning"
		ServiceType.Type.TELEPORTATION:
			return "Teleportation"
		ServiceType.Type.ILLUSION:
			return "Illusion"
		ServiceType.Type.TRANSMUTATION:
			return "Transmutation"
		ServiceType.Type.EVOCATION:
			return "Evocation"
		ServiceType.Type.ABJURATION:
			return "Abjuration"
		ServiceType.Type.CONJURATION:
			return "Conjuration"
		ServiceType.Type.NECROMANCY:
			return "Necromancy"
		ServiceType.Type.DIVINATION_SERVICE:
			return "Divination Service"
		_:
			return "Unknown"

func is_available(character: Character) -> bool:
	"""Check if service is available to character"""
	# Check level requirement
	if character.level < level_required:
		return false

	# Check gold requirement
	if character.gold < gold_required:
		return false

	# Check reputation requirements
	for faction in reputation_required.keys():
		var required_reputation = reputation_required[faction]
		if character.faction_reputation.has(faction):
			var current_reputation = character.faction_reputation[faction]
			if current_reputation < required_reputation:
				return false
		else:
			return false

	# Check item requirements
	for item_id in items_required:
		# Check if character has the required item
		pass  # Would integrate with inventory system

	# Check capacity
	if current_users >= capacity:
		return false

	return true

func get_cost(character: Character) -> int:
	"""Get cost for character to use this service"""
	var base_cost = gold_required

	# Apply quality modifiers
	match quality:
		"poor":
			base_cost *= 0.5
		"average":
			base_cost *= 1.0
		"good":
			base_cost *= 1.5
		"excellent":
			base_cost *= 2.0
		"legendary":
			base_cost *= 3.0

	# Apply reputation modifiers
	for faction in character.faction_reputation.keys():
		var reputation = character.faction_reputation[faction]
		if reputation > 0:
			base_cost *= (1.0 - (reputation * 0.1))  # 10% discount per reputation level
		elif reputation < 0:
			base_cost *= (1.0 + (abs(reputation) * 0.1))  # 10% surcharge per negative reputation

	return int(base_cost)

func can_provide_service(character: Character) -> bool:
	"""Check if service can be provided to character"""
	return is_available(character) and current_users < capacity

func start_service(character: Character):
	"""Start providing service to character"""
	if can_provide_service(character):
		current_users += 1
		# Apply cost
		var cost = get_cost(character)
		character.gold -= cost
		# Apply benefits
		apply_benefits(character)

func end_service(character: Character):
	"""End service for character"""
	if current_users > 0:
		current_users -= 1

func apply_benefits(character: Character):
	"""Apply service benefits to character"""
	for benefit in benefits:
		match benefit:
			"heal":
				character.current_hp = character.max_hp
			"rest":
				character.current_hp = character.max_hp
				character.current_mp = character.max_mp
			"experience":
				character.add_experience(100)  # Base experience gain
			"skill_training":
				# Would integrate with skill system
				pass
			"item_repair":
				# Would integrate with equipment system
				pass
			"item_upgrade":
				# Would integrate with equipment system
				pass

func get_quality_color() -> Color:
	"""Get color representing service quality"""
	match quality:
		"poor":
			return Color.RED
		"average":
			return Color.WHITE
		"good":
			return Color.GREEN
		"excellent":
			return Color.BLUE
		"legendary":
			return Color.GOLD
		_:
			return Color.WHITE

func get_availability_description() -> String:
	"""Get description of service availability"""
	match availability:
		"always":
			return "Available at all times"
		"daytime":
			return "Available during daytime hours"
		"nighttime":
			return "Available during nighttime hours"
		"specific_hours":
			return "Available during specific hours"
		_:
			return "Availability varies"
