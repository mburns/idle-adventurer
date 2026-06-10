extends Node

# Lifestyle Resource Manager
# Manages lifestyles using .tres Resource files for type safety

class_name LifestyleResourceManager

# Resource storage
var lifestyles: Dictionary = {} # lifestyle_id -> LifestyleResource
var lifestyles_by_cost: Dictionary = {} # cost_range -> Array[LifestyleResource]
var benefits: Array = [] # Array of benefit dictionaries

# Resource data loader
var data_loader: ResourceDataLoader

func _ready() -> void:
	# Use global data loader if available
	if Engine.has_singleton("AutoloadManager"):
		var autoload_manager = Engine.get_singleton("AutoloadManager")
		if autoload_manager and autoload_manager.data_loader:
			data_loader = autoload_manager.data_loader
		else:
			data_loader = ResourceDataLoader.new()
			
	else:
		data_loader = ResourceDataLoader.new()
		

	load_all_lifestyles()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Load all lifestyles from .tres files
func load_all_lifestyles() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Wait for data loader to finish loading
	await data_loader.data_loaded

	# Get lifestyles from data loader
	var all_lifestyles = data_loader.get_all_lifestyles()

	# Populate our storage
	for lifestyle_resource in all_lifestyles:
		lifestyles[lifestyle_resource.id] = lifestyle_resource
		print("Loaded lifestyle resource: " + lifestyle_resource.name)

	# Organize lifestyles by various criteria
	organize_lifestyles()

	print("Loaded " + str(lifestyles.size()) + " lifestyle resources")

# Organize lifestyles by various criteria
func organize_lifestyles() -> void:
	lifestyles_by_cost.clear()

	for lifestyle_id in lifestyles:
		var lifestyle = lifestyles[lifestyle_id]

		# Organize by cost range
		var cost_range = get_cost_range(lifestyle.daily_cost)
		if not lifestyles_by_cost.has(cost_range):
			lifestyles_by_cost[cost_range] = []
		lifestyles_by_cost[cost_range].append(lifestyle)

func get_cost_range(cost: int) -> String:
	if cost <= 1:
		return "wretched"
	elif cost <= 2:
		return "squalid"
	elif cost <= 4:
		return "poor"
	elif cost <= 10:
		return "modest"
	elif cost <= 20:
		return "comfortable"
	elif cost <= 50:
		return "wealthy"
	else:
		return "aristocratic"

# Public API methods
func get_lifestyle_by_id(lifestyle_id: String) -> LifestyleResource:
	"""Get a specific lifestyle by ID"""
	return lifestyles.get(lifestyle_id, null)

func get_lifestyles_by_cost_range(cost_range: String) -> Array[LifestyleResource]:
	"""Get all lifestyles in a specific cost range"""
	return lifestyles_by_cost.get(cost_range, [])

func get_all_lifestyles() -> Dictionary:
	"""Get all lifestyles"""
	return lifestyles.duplicate()

func get_affordable_lifestyles_for_character(character: Character) -> Array[LifestyleResource]:
	"""Get lifestyles that a character can afford"""
	var affordable = []
	for lifestyle_id in lifestyles:
		var lifestyle = lifestyles[lifestyle_id]
		if lifestyle.is_affordable_for_character(character):
			affordable.append(lifestyle)
	return affordable

func get_recommended_lifestyle_for_character(character: Character) -> LifestyleResource:
	"""Get the recommended lifestyle for a character based on their wealth"""
	var character_gold = character.get_gold()
	var daily_budget = character_gold / 30  # Monthly budget

	# Find the best lifestyle within budget
	var best_lifestyle = null
	for lifestyle_id in lifestyles:
		var lifestyle = lifestyles[lifestyle_id]
		if lifestyle.daily_cost <= daily_budget:
			if best_lifestyle == null or lifestyle.daily_cost > best_lifestyle.daily_cost:
				best_lifestyle = lifestyle

	return best_lifestyle

func get_benefit_by_id(benefit_id: String) -> Dictionary:
	"""Get benefit data by ID"""
	for benefit in benefits:
		if benefit.has("id") and benefit["id"] == benefit_id:
			return benefit
	return {}

func get_all_benefits() -> Array:
	"""Get all benefits"""
	return benefits.duplicate()
