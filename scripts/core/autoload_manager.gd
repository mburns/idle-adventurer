# Autoload manager for global game state
extends Node

# Resource managers are globally available via class_name declarations

# Global game managers
var inventory_system: InventorySystem

# Resource data loader for .tres files
var data_loader: ResourceDataLoader

# Resource managers for .tres Resource approach
var activity_manager: ActivityResourceManager
var spell_manager: SpellResourceManager
var class_manager: ClassResourceManager
var equipment_manager: EquipmentResourceManager
var race_manager: RaceResourceManager
var monster_manager: MonsterResourceManager
var magic_item_manager: MagicItemResourceManager
var language_manager: LanguageResourceManager
var currency_manager: CurrencyResourceManager
var achievement_resource_manager: AchievementResourceManager
var lifestyle_manager: LifestyleResourceManager
var name_manager: NameResourceManager
var level_requirement_manager: LevelRequirementResourceManager
var alignment_manager: AlignmentResourceManager

# Game state
var current_scene: String = ""
var game_time: float = 0.0
var is_paused: bool = false

func load_resource_classes():
	"""Load all custom resource classes to ensure they're available in headless mode"""
	print("Loading custom resource classes for headless mode...")

	# Load the resource scripts to register the classes
	var resource_scripts = [
		"res://resources/activity_resource.gd",
		"res://resources/ability_resource.gd",
		"res://resources/skill_resource.gd",
		"res://resources/item_resource.gd",
		"res://resources/feat_resource.gd"
	]

	for script_path in resource_scripts:
		var script = load(script_path)
		if script:
			print("Loaded resource script: ", script_path)
			# Force the script to be instantiated to register the class
			var instance = script.new()
			if instance:
				# Don't free references, just let them be garbage collected
				pass
		else:
			print("Failed to load resource script: ", script_path)

	print("Resource class loading complete!")

	# Test if classes are registered
	print("Testing class registration...")
	if ClassDB.class_exists("ActivityResource"):
		print("ActivityResource class is registered")
	else:
		print("ActivityResource class is NOT registered")

	if ClassDB.class_exists("AbilityResource"):
		print("AbilityResource class is registered")
	else:
		print("AbilityResource class is NOT registered")

func _ready():
	# Load custom resource classes first for headless mode compatibility
	load_resource_classes()

	# Initialize global data loader first
	data_loader = ResourceDataLoader.new()
	data_loader.load_all_data()

	# Initialize global managers
	inventory_system = InventorySystem.new()

	# Initialize resource managers with global data loader
	activity_manager = ActivityResourceManager.new()
	activity_manager.data_loader = data_loader
	activity_manager.load_all_activities()
	spell_manager = SpellResourceManager.new()
	spell_manager.data_loader = data_loader
	class_manager = ClassResourceManager.new()
	class_manager.data_loader = data_loader
	equipment_manager = EquipmentResourceManager.new()
	equipment_manager.data_loader = data_loader
	race_manager = RaceResourceManager.new()
	race_manager.data_loader = data_loader
	monster_manager = MonsterResourceManager.new()
	monster_manager.data_loader = data_loader
	magic_item_manager = MagicItemResourceManager.new()
	magic_item_manager.data_loader = data_loader
	language_manager = LanguageResourceManager.new()
	language_manager.data_loader = data_loader
	currency_manager = CurrencyResourceManager.new()
	currency_manager.data_loader = data_loader
	achievement_resource_manager = AchievementResourceManager.new()
	achievement_resource_manager.data_loader = data_loader
	lifestyle_manager = LifestyleResourceManager.new()
	lifestyle_manager.data_loader = data_loader
	name_manager = NameResourceManager.new()
	name_manager.data_loader = data_loader
	level_requirement_manager = LevelRequirementResourceManager.new()
	level_requirement_manager.data_loader = data_loader
	alignment_manager = AlignmentResourceManager.new()
	alignment_manager.data_loader = data_loader

	# Add as children
	add_child(inventory_system)
	add_child(activity_manager)
	add_child(spell_manager)
	add_child(class_manager)
	add_child(equipment_manager)
	add_child(race_manager)
	add_child(monster_manager)
	add_child(magic_item_manager)
	add_child(language_manager)
	add_child(currency_manager)
	add_child(achievement_resource_manager)
	add_child(lifestyle_manager)
	add_child(name_manager)
	add_child(level_requirement_manager)
	add_child(alignment_manager)

	# Connect signals
	CharacterManager.character_changed.connect(_on_character_changed)

func _process(delta):
	if not is_paused:
		game_time += delta

func _on_character_changed(_character: Character):
	# Notify all systems of character changes
	# TODO: Add achievement checking when AchievementManager is implemented
	pass

func pause_game():
	is_paused = true
	get_tree().paused = true

func resume_game():
	is_paused = false
	get_tree().paused = false

func get_game_time() -> float:
	return game_time

# Manager access methods
func get_inventory_system() -> InventorySystem:
	return inventory_system

# Resource manager access methods
func get_activity_manager() -> ActivityResourceManager:
	return activity_manager

func get_spell_manager() -> SpellResourceManager:
	return spell_manager

func get_class_manager() -> ClassResourceManager:
	return class_manager

func get_equipment_manager() -> EquipmentResourceManager:
	return equipment_manager

func get_race_manager() -> RaceResourceManager:
	return race_manager

func get_monster_manager() -> MonsterResourceManager:
	return monster_manager

func get_magic_item_manager() -> MagicItemResourceManager:
	return magic_item_manager

func get_language_manager() -> LanguageResourceManager:
	return language_manager

func get_currency_manager() -> CurrencyResourceManager:
	return currency_manager

func get_achievement_resource_manager() -> AchievementResourceManager:
	return achievement_resource_manager

func get_lifestyle_manager() -> LifestyleResourceManager:
	return lifestyle_manager

func get_name_manager() -> NameResourceManager:
	return name_manager

func get_level_requirement_manager() -> LevelRequirementResourceManager:
	return level_requirement_manager

func get_alignment_manager() -> AlignmentResourceManager:
	return alignment_manager
