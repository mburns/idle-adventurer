# Headless test runner for CI/CD
extends SceneTree

func _init():
    print("Starting test suite...")

    # Load the test runner scene
    var test_runner_scene = preload("res://scenes/test_runner.tscn")
    var test_runner = test_runner_scene.instantiate()

    # Add to scene tree
    root.add_child(test_runner)

    # Connect to test completion signal
    test_runner.get_node("Gut").all_tests_finished.connect(_on_tests_finished)

    # Start tests
    test_runner.get_node("Gut").run_tests()

func _on_tests_finished():
    var gut = root.get_child(0).get_node("Gut")
    var summary = gut.get_summary()

    print("\n=== TEST RESULTS ===")
    print("Total: %d" % summary.tests)
    print("Passed: %d" % summary.passed)
    print("Failed: %d" % summary.failed)
    print("Warnings: %d" % summary.warnings)

    # Exit with error code if tests failed
    if summary.failed > 0:
        print("Tests failed!")
        quit(1)
    else:
        print("All tests passed!")
        quit(0)
