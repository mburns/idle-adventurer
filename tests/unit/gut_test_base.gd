# Base class for GUT tests
class_name GutTest
extends Node

# Reference to the GUT instance
var gut: Node

func _init():
	# Find the GUT instance in the scene tree
	# This will be called when the test instance is created
	call_deferred("_find_gut_instance")

func _find_gut_instance():
	# Try to find GUT instance in the scene tree
	if get_tree():
		gut = get_tree().get_first_node_in_group("gut")
		if gut == null:
			# If not found in group, try to find by script
			var nodes = get_tree().get_nodes_in_group("")
			for node in nodes:
				if node.get_script() and node.get_script().get_path().ends_with("gut.gd"):
					gut = node
					break

	if gut == null:
		push_error("GUT instance not found! Tests will not work properly.")

# Assertion methods that delegate to GUT
func assert_true(condition: bool, message: String = ""):
	if gut:
		gut.assert_true(condition, message)
	else:
		push_error("GUT not available: " + message)

func assert_false(condition: bool, message: String = ""):
	if gut:
		gut.assert_false(condition, message)
	else:
		push_error("GUT not available: " + message)

func assert_eq(actual, expected, message: String = ""):
	if gut:
		gut.assert_eq(actual, expected, message)
	else:
		push_error("GUT not available: " + message)

func assert_ne(actual, expected, message: String = ""):
	if gut:
		gut.assert_ne(actual, expected, message)
	else:
		push_error("GUT not available: " + message)

func assert_gt(actual, expected, message: String = ""):
	if gut:
		gut.assert_gt(actual, expected, message)
	else:
		push_error("GUT not available: " + message)

func assert_lt(actual, expected, message: String = ""):
	if gut:
		gut.assert_lt(actual, expected, message)
	else:
		push_error("GUT not available: " + message)

func assert_ge(actual, expected, message: String = ""):
	if gut:
		gut.assert_ge(actual, expected, message)
	else:
		push_error("GUT not available: " + message)

func assert_le(actual, expected, message: String = ""):
	if gut:
		gut.assert_le(actual, expected, message)
	else:
		push_error("GUT not available: " + message)

func assert_not_null(value, message: String = ""):
	if gut:
		gut.assert_not_null(value, message)
	else:
		push_error("GUT not available: " + message)

func assert_null(value, message: String = ""):
	if gut:
		gut.assert_null(value, message)
	else:
		push_error("GUT not available: " + message)
