extends Node

# Language Resource Manager
# Manages languages using .tres Resource files for type safety

class_name LanguageResourceManager

# Resource storage
var languages: Dictionary = {} # language_id -> LanguageResource
var languages_by_category: Dictionary = {} # category -> Array[LanguageResource]
var languages_by_difficulty: Dictionary = {} # difficulty -> Array[LanguageResource]

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
		

	load_all_languages()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Load all languages from .tres files
func load_all_languages() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Wait for data loader to finish loading
	await data_loader.data_loaded

	# Get languages from data loader
	var all_languages = data_loader.get_all_languages()

	# Populate our storage
	for language_id in all_languages.keys():
		var language_data = all_languages[language_id]
		languages[language_id] = language_data

	# Organize languages by various criteria
	organize_languages()

	print("Loaded " + str(languages.size()) + " language resources")

# Load a single language from .tres file (legacy method for compatibility)
func load_language_from_file(file_path: String) -> void:
	print("Warning: load_language_from_file is deprecated, use load_all_languages() instead")

# Organize languages by various criteria
func organize_languages() -> void:
	languages_by_category.clear()
	languages_by_difficulty.clear()

	for language_id in languages:
		var language = languages[language_id]

		# Organize by category
		var category = language.get("category", "unknown")
		if not languages_by_category.has(category):
			languages_by_category[category] = []
		languages_by_category[category].append(language)

		# Organize by difficulty
		var difficulty = language.get("difficulty", 1)
		if not languages_by_difficulty.has(difficulty):
			languages_by_difficulty[difficulty] = []
		languages_by_difficulty[difficulty].append(language)

# Public API methods
func get_language_by_id(language_id: String) -> Dictionary:
	"""Get a specific language by ID"""
	return languages.get(language_id, {})

func get_languages_by_category(category: String) -> Array:
	"""Get all languages in a specific category"""
	return languages_by_category.get(category, [])

func get_languages_by_difficulty(difficulty: int) -> Array:
	"""Get all languages of a specific difficulty"""
	return languages_by_difficulty.get(difficulty, [])

func get_all_languages() -> Dictionary:
	"""Get all languages"""
	return languages.duplicate()

func get_available_languages_for_character(character_level: int) -> Array[LanguageResource]:
	"""Get languages that a character can learn based on their level"""
	var available = []
	for language_id in languages:
		var language = languages[language_id]
		if language.can_learn(character_level):
			available.append(language)
	return available

func get_recommended_languages(character_level: int, category: String = "") -> Array[LanguageResource]:
	"""Get recommended languages for a character"""
	var available = get_available_languages_for_character(character_level)

	if category != "":
		available = available.filter(func(lang): return lang.category == category)

	# Sort by difficulty (easier first)
	available.sort_custom(func(a, b): return a.difficulty < b.difficulty)

	return available
