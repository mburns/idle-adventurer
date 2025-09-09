# Base class for all tests
class_name TestBase
extends Node

# This class provides common testing utilities and setup
# All test classes should extend this

func before_each():
	# Override in test classes
	pass

func after_each():
	# Override in test classes
	pass

# Helper method to create a test character
func create_test_character(name: String = "Test Character", race: String = "Human", character_class: String = "Barbarian", background: String = "Folk Hero") -> Character:
	var character = Character.new()
	character.name = name
	character.race = race
	character.character_class = character_class
	character.background = background
	character.update_derived_stats()
	return character

# Helper method to create a character manager
func create_test_character_manager() -> CharacterManager:
	var manager = CharacterManager.new()
	manager.save_file_path = "user://test_character_save.dat"
	return manager

# Helper method to clean up test files
func cleanup_test_files():
	var test_files = [
		"user://test_character_save.dat",
		"user://character_save.dat"
	]
	
	for file_path in test_files:
		if FileAccess.file_exists(file_path):
			var dir = DirAccess.open("user://")
			dir.remove(file_path)
