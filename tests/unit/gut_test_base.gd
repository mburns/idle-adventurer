# Base class for GUT tests
class_name GutTest
extends Node

# Reference to the GUT instance
var gut: Node

func set_gut_instance(gut_instance: Node):
	gut = gut_instance

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
