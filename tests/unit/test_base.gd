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
func create_test_character(character_name: String = "Test Character", race: String = "Human", character_class: String = "Barbarian", background: String = "Folk Hero") -> Character:
    var character = Character.new()
    character.name = character_name
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

# Assertion functions for testing
func assert_not_null(value, message: String = ""):
    if value == null:
        push_error("ASSERTION FAILED: " + message + " - Expected not null, got null")
        return false
    return true

func assert_null(value, message: String = ""):
    if value != null:
        push_error("ASSERTION FAILED: " + message + " - Expected null, got " + str(value))
        return false
    return true

func assert_eq(actual, expected, message: String = ""):
    if actual != expected:
        push_error("ASSERTION FAILED: " + message + " - Expected " + str(expected) + ", got " + str(actual))
        return false
    return true

func assert_ne(actual, expected, message: String = ""):
    if actual == expected:
        push_error("ASSERTION FAILED: " + message + " - Expected not equal to " + str(expected) + ", got " + str(actual))
        return false
    return true

func assert_true(condition, message: String = ""):
    if not condition:
        push_error("ASSERTION FAILED: " + message + " - Expected true, got false")
        return false
    return true

func assert_false(condition, message: String = ""):
    if condition:
        push_error("ASSERTION FAILED: " + message + " - Expected false, got true")
        return false
    return true

func assert_gt(actual, expected, message: String = ""):
    if actual <= expected:
        push_error("ASSERTION FAILED: " + message + " - Expected " + str(actual) + " > " + str(expected))
        return false
    return true

func assert_lt(actual, expected, message: String = ""):
    if actual >= expected:
        push_error("ASSERTION FAILED: " + message + " - Expected " + str(actual) + " < " + str(expected))
        return false
    return true

func assert_ge(actual, expected, message: String = ""):
    if actual < expected:
        push_error("ASSERTION FAILED: " + message + " - Expected " + str(actual) + " >= " + str(expected))
        return false
    return true

func assert_le(actual, expected, message: String = ""):
    if actual > expected:
        push_error("ASSERTION FAILED: " + message + " - Expected " + str(actual) + " <= " + str(expected))
        return false
    return true
