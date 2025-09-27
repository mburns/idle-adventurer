extends Node

# Name Resource Manager
# Manages names using the hybrid YAML + Resource approach

class_name NameResourceManager

# Resource storage
var first_names: Array[NameResource] = []
var last_names: Array[NameResource] = []
var names_by_category: Dictionary = {} # category -> Array[NameResource]
var names_by_gender: Dictionary = {} # gender -> Array[NameResource]

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

	# Connect to data loaded signal
	if data_loader and data_loader.has_signal("data_loaded"):
		data_loader.data_loaded.connect(_on_data_loaded)

	load_all_names()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Signal handler for data loading
func _on_data_loaded(data_type: String, count: int) -> void:
	if data_type == "names":
		_load_names_from_data_loader()

# Load all names from resource file
func load_all_names() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Try to load names immediately if data is already available
	_load_names_from_data_loader()

# Internal method to load names from data loader
func _load_names_from_data_loader() -> void:
	if not data_loader:
		return

	var names_data = data_loader.get_all_names()
	if names_data.is_empty():
		return

	# Process names data - this should be an array of NameResource objects
	if names_data is Array:
		for name_resource in names_data:
			if name_resource is NameResource:
				if name_resource.category == "first_name":
					first_names.append(name_resource)
				elif name_resource.category == "last_name":
					last_names.append(name_resource)

	print("Loaded " + str(first_names.size()) + " first names and " + str(last_names.size()) + " last names")

# Organize names by various criteria
func organize_names() -> void:
	names_by_category.clear()
	names_by_gender.clear()

	# Organize first names
	for name_resource in first_names:
		# Organize by category
		if not names_by_category.has(name_resource.category):
			names_by_category[name_resource.category] = []
		names_by_category[name_resource.category].append(name_resource)

		# Organize by gender
		if not names_by_gender.has(name_resource.gender):
			names_by_gender[name_resource.gender] = []
		names_by_gender[name_resource.gender].append(name_resource)

# Public API methods
func get_random_first_name() -> NameResource:
	"""Get a random first name"""
	if first_names.is_empty():
		return null
	return first_names[randi() % first_names.size()]

func get_random_last_name() -> NameResource:
	"""Get a random last name"""
	if last_names.is_empty():
		return null
	return last_names[randi() % last_names.size()]

func get_random_full_name() -> String:
	"""Get a random full name"""
	var first = get_random_first_name()
	var last = get_random_last_name()

	if first == null or last == null:
		return "Unknown"

	return first.name + " " + last.name

func get_names_by_category(category: String) -> Array[NameResource]:
	"""Get all names in a specific category"""
	return names_by_category.get(category, [])

func get_names_by_gender(gender: String) -> Array[NameResource]:
	"""Get all names of a specific gender"""
	return names_by_gender.get(gender, [])

func get_all_first_names() -> Array[NameResource]:
	"""Get all first names"""
	return first_names.duplicate()

func get_all_last_names() -> Array[NameResource]:
	"""Get all last names"""
	return last_names.duplicate()

func generate_character_name(_character: Character) -> String:
	"""Generate a name for a character based on their traits"""
	# TODO This could be enhanced to consider character race, culture, etc.
	return get_random_full_name()
