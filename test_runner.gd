extends Control

@onready var gut = $Gut
@onready var test_results = $VBoxContainer/TestResults

func _ready():
    # Configure GUT
    if gut and gut.has_method("set_include_subdirs"):
        gut.set_include_subdirs(true)
        gut.set_test_prefix("test_")
        gut.set_should_print_to_console(true)
        gut.set_yield_between_tests(true)
        gut.set_yield_between_asserts(true)
    else:
        print("Error: Gut node not properly initialized or missing methods")
        print("Gut node: ", gut)
        if gut:
            print("Gut methods: ", gut.get_method_list())

    # Connect GUT signals
    if gut and gut.has_signal("test_finished") and gut.has_signal("all_tests_finished"):
        gut.test_finished.connect(_on_test_finished)
        gut.all_tests_finished.connect(_on_all_tests_finished)
    else:
        print("Error: Gut signals not available")
        if gut:
            print("Gut signals: ", gut.get_signal_list())

    # Auto-run tests in headless mode
    if OS.has_feature("headless") or OS.has_feature("server"):
        print("Running tests automatically in headless mode...")
        # Wait for autoloads to initialize
        await get_tree().process_frame
        await get_tree().process_frame
        await get_tree().process_frame

        # Check if AutoloadManager is ready
        if AutoloadManager and AutoloadManager.data_loader:
            print("AutoloadManager and data loader are ready")
        else:
            print("Warning: AutoloadManager or data loader not ready, proceeding anyway")

        _on_run_tests_button_pressed()

func _on_run_tests_button_pressed():
    test_results.text = "Running tests...\n"
    if gut and gut.has_method("run_tests"):
        gut.run_tests()
    else:
        test_results.text += "Error: Cannot run tests - Gut not properly initialized\n"

func _on_test_finished(test_name: String, did_pass: bool):
    var color = "green" if did_pass else "red"
    var status = "PASS" if did_pass else "FAIL"
    test_results.append_text("[color=%s]%s: %s[/color]\n" % [color, status, test_name])

func _on_all_tests_finished():
    if gut and gut.has_method("get_summary"):
        var summary = gut.get_summary()
        test_results.append_text("\n[color=yellow]Test Summary:[/color]\n")
        test_results.append_text("Total: %d\n" % summary.tests)
        test_results.append_text("Passed: %d\n" % summary.passed)
        test_results.append_text("Failed: %d\n" % summary.failed)
        test_results.append_text("Warnings: %d\n" % summary.warnings)
    else:
        test_results.append_text("\n[color=red]Error: Cannot get test summary[/color]\n")
