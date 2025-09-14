class_name InteractionType
extends RefCounted

# Static data loaded from YAML
static var interaction_data: Dictionary = {}
static var interaction_types: Array = []
static var interaction_categories: Dictionary = {}
static var type_data: Dictionary = {}

# Dynamic constants - populated from YAML
static var TALK: String = "TALK"
static var TRADE: String = "TRADE"
static var TRAIN: String = "TRAIN"
static var QUEST: String = "QUEST"
static var HEAL: String = "HEAL"
static var REPAIR: String = "REPAIR"
static var GIVE_GIFT: String = "GIVE_GIFT"
static var STEAL: String = "STEAL"
static var ATTACK: String = "ATTACK"
static var GATHER_INFO: String = "GATHER_INFO"
static var RECRUIT: String = "RECRUIT"
static var BARGAIN: String = "BARGAIN"
static var FLIRT: String = "FLIRT"
static var INTIMIDATE: String = "INTIMIDATE"
static var PERSUADE: String = "PERSUADE"
static var GREETING: String = "GREETING"
static var SMALL_TALK: String = "SMALL_TALK"
static var DEEP_CONVERSATION: String = "DEEP_CONVERSATION"
static var BUSINESS: String = "BUSINESS"
static var TRAINING: String = "TRAINING"
static var QUEST_GIVING: String = "QUEST_GIVING"
static var ROMANCE: String = "ROMANCE"
static var CONFLICT: String = "CONFLICT"
static var HELP_REQUEST: String = "HELP_REQUEST"
static var GOSSIP: String = "GOSSIP"

# Initialize the interaction types from YAML data
static func _static_init():
	load_interaction_types()

# Load interaction types from YAML file
# NOTE: The current YAMLParser has limitations with complex nested structures
# If this fails, consider using JSON instead or a more robust YAML parser
static func load_interaction_types() -> void:
	var file_path = "res://data/interaction_types.yaml"
	var yaml_parser = YAMLParser.new()
	var data = yaml_parser.parse_yaml_file(file_path)

	if data.is_empty():
		push_error("CRITICAL: Could not load interaction types from " + file_path)
		assert(false, "Failed to load interaction types YAML - game cannot continue")
		return

	# Check if interaction_types exists and is an array
	if not data.has("interaction_types"):
		push_error("CRITICAL: No 'interaction_types' key found in YAML file: " + file_path)
		assert(false, "Missing 'interaction_types' key in YAML - game cannot continue")
		return

	var types_data = data["interaction_types"]
	if not types_data is Array:
		push_error("CRITICAL: 'interaction_types' is not an array in YAML file: " + file_path)
		assert(false, "'interaction_types' must be an array in YAML - game cannot continue")
		return

	interaction_types = types_data

	# Build the type_data dictionary
	type_data.clear()

	for interaction in interaction_types:
		var id = interaction.get("id", "")
		if id != "":
			type_data[id] = interaction

	print("Successfully loaded ", interaction_types.size(), " interaction types from YAML")


# Get interaction type data by string ID
static func get_interaction_type_by_id(id: String) -> Dictionary:
	return type_data.get(id, {})

# Get interaction type data by Type value (string ID)
static func get_interaction_type(type_id: String) -> Dictionary:
	return type_data.get(type_id, {})

# Get all interaction types
static func get_all_interaction_types() -> Array[Dictionary]:
	return interaction_types

# Get interaction types by category
static func get_interaction_types_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for interaction in interaction_types:
		if interaction.get("category", "") == category:
			result.append(interaction)
	return result

# Get interaction categories
static func get_interaction_categories() -> Dictionary:
	return interaction_categories

# Check if an interaction type exists
static func has_interaction_type(type_id: String) -> bool:
	return type_data.has(type_id)

# Get interaction type name
static func get_interaction_name(type_id: String) -> String:
	var interaction = get_interaction_type(type_id)
	return interaction.get("name", type_id)

# Get interaction type description
static func get_interaction_description(type_id: String) -> String:
	var interaction = get_interaction_type(type_id)
	return interaction.get("description", "")

# Get interaction type category
static func get_interaction_category(type_id: String) -> String:
	var interaction = get_interaction_type(type_id)
	return interaction.get("category", "unknown")

# Get interaction type priority
static func get_interaction_priority(type_id: String) -> int:
	var interaction = get_interaction_type(type_id)
	return interaction.get("priority", 999)

# Get interaction type color
static func get_interaction_color(type_id: String) -> String:
	var interaction = get_interaction_type(type_id)
	return interaction.get("color", "#FFFFFF")

# Get interaction type icon
static func get_interaction_icon(type_id: String) -> String:
	var interaction = get_interaction_type(type_id)
	return interaction.get("icon", "default")

# Get required relationship level
static func get_required_relationship(type_id: String) -> int:
	var interaction = get_interaction_type(type_id)
	return interaction.get("requires_relationship", 0)

# Get base duration in minutes
static func get_base_duration(type_id: String) -> int:
	var interaction = get_interaction_type(type_id)
	return interaction.get("base_duration", 30)
