# GUT (Godot Unit Testing) - Simplified version for this project
# This is a minimal implementation for testing purposes

extends Node

signal test_finished(test_name, did_pass)
signal all_tests_finished()

var test_prefix = "test_"
var include_subdirs = true
var should_print_to_console = true
var yield_between_tests = true
var yield_between_asserts = true

var tests = []
var current_test_index = 0
var test_results = {
    "tests": 0,
    "passed": 0,
    "failed": 0,
    "warnings": 0
}

# Track assertion failures
var current_test_failed = false
var assertion_count = 0
var failed_assertions = []

func set_include_subdirs(value: bool):
    include_subdirs = value

func set_test_prefix(value: String):
    test_prefix = value

func set_should_print_to_console(value: bool):
    should_print_to_console = value

func set_yield_between_tests(value: bool):
    yield_between_tests = value

func set_yield_between_asserts(value: bool):
    yield_between_asserts = value

func run_tests():
    tests.clear()
    test_results = {"tests": 0, "passed": 0, "failed": 0, "warnings": 0}
    current_test_index = 0
    assertion_count = 0
    failed_assertions.clear()

    # Find all test files
    _find_test_files("res://tests/")

    # Run tests
    await _run_test_suite()

func _find_test_files(path: String):
    var dir = DirAccess.open(path)
    if dir == null:
        return

    for file_name in dir.get_files():
        if file_name.ends_with(".gd"):
            var file_path = path + file_name
            tests.append(file_path)

    if include_subdirs:
        for dir_name in dir.get_directories():
            _find_test_files(path + dir_name + "/")

func _run_test_suite():
    for test_file in tests:
        await _run_test_file(test_file)

    all_tests_finished.emit()

func _run_test_file(file_path: String):
    var test_script = load(file_path)
    if test_script == null:
        return

    var test_instance = Node.new()
    test_instance.set_script(test_script)

    # Pass GUT instance to the test
    if test_instance.has_method("set_gut_instance"):
        test_instance.set_gut_instance(self)

    add_child(test_instance)

    # Find all test methods
    var test_methods = []
    for method_name in test_instance.get_method_list():
        if method_name.name.begins_with(test_prefix):
            test_methods.append(method_name.name)

    # Run each test method
    for method_name in test_methods:
        await _run_test_method(test_instance, method_name)

    remove_child(test_instance)
    test_instance.queue_free()

func _run_test_method(test_instance: Node, method_name: String):
    test_results.tests += 1
    current_test_failed = false
    assertion_count = 0

    # Call before_each if it exists
    if test_instance.has_method("before_each"):
        test_instance.before_each()

    # Run the test
    var test_passed = true
    if test_instance.has_method(method_name):
        test_instance.call(method_name)
        test_passed = not current_test_failed
    else:
        test_passed = false
        push_error("Test method " + method_name + " not found")

    # Call after_each if it exists
    if test_instance.has_method("after_each"):
        test_instance.after_each()

    if test_passed:
        test_results.passed += 1
        if should_print_to_console:
            print("✅ " + method_name + " - PASSED")
    else:
        test_results.failed += 1
        if should_print_to_console:
            print("❌ " + method_name + " - FAILED")
            for assertion in failed_assertions:
                print("   " + assertion)

    test_finished.emit(method_name, test_passed)

    if yield_between_tests:
        await get_tree().process_frame

func get_summary() -> Dictionary:
    return test_results

# Enhanced assertion functions that track failures
func assert_true(condition: bool, message: String = ""):
    assertion_count += 1
    if not condition:
        var error_msg = "Assertion failed: " + message
        push_error(error_msg)
        failed_assertions.append(error_msg)
        current_test_failed = true
        return false
    return true

func assert_false(condition: bool, message: String = ""):
    return assert_true(not condition, message)

func assert_eq(actual, expected, message: String = ""):
    var full_message = message + " (expected: " + str(expected) + ", actual: " + str(actual) + ")"
    return assert_true(actual == expected, full_message)

func assert_ne(actual, expected, message: String = ""):
    return assert_true(actual != expected, message)

func assert_gt(actual, expected, message: String = ""):
    return assert_true(actual > expected, message)

func assert_lt(actual, expected, message: String = ""):
    return assert_true(actual < expected, message)

func assert_ge(actual, expected, message: String = ""):
    return assert_true(actual >= expected, message)

func assert_le(actual, expected, message: String = ""):
    return assert_true(actual <= expected, message)

func assert_not_null(value, message: String = ""):
    return assert_true(value != null, message)

func assert_null(value, message: String = ""):
    return assert_true(value == null, message)
