extends Node

# Alignment Resource Manager
# Manages alignments using .tres Resource files for type safety

class_name AlignmentResourceManager

# Resource storage
var alignments: Dictionary = {} # alignment_id -> AlignmentResource
var alignments_by_moral: Dictionary = {} # moral_axis -> Array[AlignmentResource]
var alignments_by_ethical: Dictionary = {} # ethical_axis -> Array[AlignmentResource]

# Resource data loader
var data_loader: ResourceDataLoader

func _ready() -> void:
	# Use global data loader if available
	if Engine.has_singleton("AutoloadManager"):
		var autoload_manager = Engine.get_singleton("AutoloadManager")
		if autoload_manager and autoload_manager.data_loader:
			data_loader = autoload_manager.data_loader
		else:
			data_loader = ResourceDataLoader.new()
			
	else:
		data_loader = ResourceDataLoader.new()
		

	load_all_alignments()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Load all alignments from .tres files
func load_all_alignments() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Wait for data loader to finish loading
	await data_loader.data_loaded

	# Get alignments from data loader
	var all_alignments = data_loader.get_all_alignments()

	# Populate our storage
	for alignment_resource in all_alignments:
		alignments[alignment_resource.id] = alignment_resource

	# Organize alignments by various criteria
	organize_alignments()

	print("Loaded " + str(alignments.size()) + " alignment resources")

# Organize alignments by various criteria
func organize_alignments() -> void:
	alignments_by_moral.clear()
	alignments_by_ethical.clear()

	for alignment_id in alignments:
		var alignment = alignments[alignment_id]

		# Group by moral axis
		if not alignments_by_moral.has(alignment.moral_axis):
			alignments_by_moral[alignment.moral_axis] = []
		alignments_by_moral[alignment.moral_axis].append(alignment)

		# Group by ethical axis
		if not alignments_by_ethical.has(alignment.ethical_axis):
			alignments_by_ethical[alignment.ethical_axis] = []
		alignments_by_ethical[alignment.ethical_axis].append(alignment)

# API Methods
func get_alignment_by_id(alignment_id: String) -> AlignmentResource:
	"""Get alignment by ID"""
	return alignments.get(alignment_id, null)

func get_alignment_by_name(name: String) -> AlignmentResource:
	"""Get alignment by name"""
	for alignment_id in alignments:
		var alignment = alignments[alignment_id]
		if alignment.name.to_lower() == name.to_lower():
			return alignment
	return null

func get_alignments_by_moral(moral_axis: String) -> Array[AlignmentResource]:
	"""Get all alignments with specific moral axis"""
	return alignments_by_moral.get(moral_axis, [] as Array[AlignmentResource])

func get_alignments_by_ethical(ethical_axis: String) -> Array[AlignmentResource]:
	"""Get all alignments with specific ethical axis"""
	return alignments_by_ethical.get(ethical_axis, [] as Array[AlignmentResource])

func get_all_alignments() -> Dictionary:
	"""Get all alignments"""
	return alignments.duplicate()

func get_lawful_alignments() -> Array[AlignmentResource]:
	"""Get all lawful alignments"""
	return get_alignments_by_moral("lawful")

func get_chaotic_alignments() -> Array[AlignmentResource]:
	"""Get all chaotic alignments"""
	return get_alignments_by_moral("chaotic")

func get_good_alignments() -> Array[AlignmentResource]:
	"""Get all good alignments"""
	return get_alignments_by_ethical("good")

func get_evil_alignments() -> Array[AlignmentResource]:
	"""Get all evil alignments"""
	return get_alignments_by_ethical("evil")

func get_neutral_alignments() -> Array[AlignmentResource]:
	"""Get all neutral alignments (moral or ethical)"""
	var neutral_alignments: Array[AlignmentResource] = []
	neutral_alignments.append_array(get_alignments_by_moral("neutral"))
	neutral_alignments.append_array(get_alignments_by_ethical("neutral"))
	return neutral_alignments
