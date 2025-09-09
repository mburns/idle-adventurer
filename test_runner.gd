extends Control

@onready var gut = $Gut
@onready var test_results = $VBoxContainer/TestResults

func _ready():
	# Configure GUT
	gut.set_include_subdirs(true)
	gut.set_test_prefix("test_")
	gut.set_should_print_to_console(true)
	gut.set_yield_between_tests(true)
	gut.set_yield_between_asserts(true)
	
	# Connect GUT signals
	gut.test_finished.connect(_on_test_finished)
	gut.all_tests_finished.connect(_on_all_tests_finished)

func _on_run_tests_button_pressed():
	test_results.text = "Running tests...\n"
	gut.run_tests()

func _on_test_finished(test_name: String, did_pass: bool):
	var color = "green" if did_pass else "red"
	var status = "PASS" if did_pass else "FAIL"
	test_results.append_text("[color=%s]%s: %s[/color]\n" % [color, status, test_name])

func _on_all_tests_finished():
	var summary = gut.get_summary()
	test_results.append_text("\n[color=yellow]Test Summary:[/color]\n")
	test_results.append_text("Total: %d\n" % summary.tests)
	test_results.append_text("Passed: %d\n" % summary.passed)
	test_results.append_text("Failed: %d\n" % summary.failed)
	test_results.append_text("Warnings: %d\n" % summary.warnings)
