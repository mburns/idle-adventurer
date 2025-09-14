extends Node

# Core character manager - coordinates character creation, persistence, and management

# Preload required classes
const CharacterCreation = preload("res://scripts/core/character_creation.gd")
const CharacterPersistence = preload("res://scripts/core/character_persistence.gd")
const StartingEquipment = preload("res://scripts/data/starting_equipment.gd")
# Simplified version that delegates to specialized modules

# CharacterManager - autoload singleton

# Current character instance
var current_character: Character

# Save file path
var save_file_path: String = "user://characters/"

# Module instances
var character_creation: CharacterCreation
var character_persistence: CharacterPersistence
var starting_equipment: StartingEquipment

# Signals
signal character_changed(character: Character)
signal character_created(character: Character)
signal character_loaded(character: Character)

func _ready() -> void:
	# Initialize modules lazily to avoid autoload dependency issues
	_initialize_modules()

	# Wait for DataLoader to finish loading
	await get_tree().process_frame
	if current_character == null:
		create_default_character()

func _initialize_modules() -> void:
	"""Initialize modules if not already initialized"""
	if character_creation == null:
		character_creation = CharacterCreation.new()
		character_creation.character_created.connect(_on_character_created)

	if character_persistence == null:
		character_persistence = CharacterPersistence.new()
		character_persistence.character_loaded.connect(_on_character_loaded)

	if starting_equipment == null:
		starting_equipment = StartingEquipment.new()
		starting_equipment.equipment_assigned.connect(_on_equipment_assigned)

# Create a new character with specified parameters
func create_character(character_name: String, race: String, character_class: String, background: String) -> Character:
	_initialize_modules()  # Ensure modules are initialized

	if not character_creation.validate_character_creation(character_name, race, character_class, background):
		print("Invalid character creation parameters")
		return null

	var character = character_creation.create_character(character_name, race, character_class, background)
	if character == null:
		return null

	# Assign starting equipment
	starting_equipment.assign_starting_equipment(character, character_class, background)

	current_character = character
	character_changed.emit(character)

	return character

# Create a random character for testing
func create_random_character() -> Character:
	_initialize_modules()  # Ensure modules are initialized

	var character = character_creation.create_random_character()
	if character == null:
		return null

	# Assign starting equipment
	starting_equipment.assign_starting_equipment(character, character.character_class, character.background)

	current_character = character
	character_changed.emit(character)

	return character

# Create default character
func create_default_character() -> Character:
	return create_random_character()

# Save current character
func save_character() -> bool:
	_initialize_modules()  # Ensure modules are initialized

	if current_character == null:
		print("No character to save")
		return false

	return character_persistence.save_character(current_character)

# Load character from save file
func load_character() -> bool:
	_initialize_modules()  # Ensure modules are initialized

	var character = character_persistence.load_character()
	if character == null:
		return false

	current_character = character
	character_changed.emit(character)
	return true

# Get current character
func get_current_character() -> Character:
	return current_character

# Set current character
func set_current_character(character: Character) -> void:
	current_character = character
	character_changed.emit(character)

# Check if save file exists
func has_save_file() -> bool:
	_initialize_modules()  # Ensure modules are initialized
	return character_persistence.has_save_file()

# Delete save file
func delete_save_file() -> bool:
	_initialize_modules()  # Ensure modules are initialized
	return character_persistence.delete_save_file()

# Get available character creation options
func get_available_races() -> Array[String]:
	_initialize_modules()  # Ensure modules are initialized
	return character_creation.get_available_races()

func get_available_classes() -> Array[String]:
	_initialize_modules()  # Ensure modules are initialized
	return character_creation.get_available_classes()

func get_available_backgrounds() -> Array[String]:
	_initialize_modules()  # Ensure modules are initialized
	return character_creation.get_available_backgrounds()

# Get starting equipment options for a class
func get_starting_equipment_options(class_type: String) -> Dictionary:
	_initialize_modules()  # Ensure modules are initialized
	return starting_equipment.get_starting_equipment_options(class_type)

# Validate character creation
func validate_character_creation(character_name: String, race: String, class_type: String, background: String) -> bool:
	_initialize_modules()  # Ensure modules are initialized
	return character_creation.validate_character_creation(character_name, race, class_type, background)

# Get character creation module (for advanced usage)
func get_character_creation_module() -> CharacterCreation:
	return character_creation

# Get character persistence module (for advanced usage)
func get_character_persistence_module() -> CharacterPersistence:
	return character_persistence

# Get starting equipment module (for advanced usage)
func get_starting_equipment_module() -> StartingEquipment:
	return starting_equipment

# Load character for testing
func load_test_character() -> Character:
	"""Load a character from test file"""
	return character_persistence.load_character_from_path(save_file_path + "test_integration.dat")

# Signal handlers
func _on_character_created(character: Character) -> void:
	character_created.emit(character)

func _on_character_loaded(character: Character) -> void:
	character_loaded.emit(character)

func _on_equipment_assigned(character: Character, _equipment: Dictionary) -> void:
	print("Starting equipment assigned to " + character.name)
