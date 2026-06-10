extends Node

# Currency Resource Manager
# Manages currencies using .tres Resource files for type safety

class_name CurrencyResourceManager

# Resource storage
var currencies: Dictionary = {} # currency_id -> CurrencyResource
var currencies_by_rarity: Dictionary = {} # rarity -> Array[CurrencyResource]
var currencies_by_material: Dictionary = {} # material -> Array[CurrencyResource]
var exchange_rates: Dictionary = {} # from_coin -> to_coin: rate

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
		

	load_all_currencies()

func _init():
	# Initialize data loader early for immediate use
	data_loader = ResourceDataLoader.new()

# Load all currencies from .tres files
func load_all_currencies() -> void:
	if not data_loader:
		print("Error: Data loader not initialized")
		return

	# Wait for data loader to finish loading
	await data_loader.data_loaded

	# Get currencies from data loader
	var all_currencies = data_loader.get_all_currencies()

	# Populate our storage
	for currency_id in all_currencies.keys():
		var currency_data = all_currencies[currency_id]
		currencies[currency_id] = currency_data

	# Organize currencies by various criteria
	organize_currencies()

	print("Loaded " + str(currencies.size()) + " currency resources")

# Load a single currency from YAML file
func load_currency_from_file(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Warning: Could not open file: " + file_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	# This method is deprecated - use load_all_currencies() instead
	print("Warning: load_currency_from_file is deprecated")
	# This method is deprecated - use load_all_currencies() instead
	print("Warning: load_currency_from_file is deprecated, use load_all_currencies() instead")

# Load exchange rates
func load_exchange_rates(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Warning: Could not open exchange rates file: " + file_path)
		return

	var yaml_string = file.get_as_text()
	file.close()

	# This method is deprecated - use load_all_currencies() instead
	print("Warning: load_currency_from_file is deprecated")
	# This method is deprecated - exchange rates are now loaded with currencies
	print("Warning: load_exchange_rates is deprecated")
	print("Loaded exchange rates for " + str(exchange_rates.size()) + " currencies")

# Organize currencies by various criteria
func organize_currencies() -> void:
	currencies_by_rarity.clear()
	currencies_by_material.clear()

	for currency_id in currencies:
		var currency = currencies[currency_id]

		# Organize by rarity
		if not currencies_by_rarity.has(currency.rarity):
			currencies_by_rarity[currency.rarity] = []
		currencies_by_rarity[currency.rarity].append(currency)

		# Organize by material
		if not currencies_by_material.has(currency.material):
			currencies_by_material[currency.material] = []
		currencies_by_material[currency.material].append(currency)

# Public API methods
func get_currency_by_id(currency_id: String) -> CurrencyResource:
	"""Get a specific currency by ID"""
	return currencies.get(currency_id, null)

func get_currencies_by_rarity(rarity: String) -> Array[CurrencyResource]:
	"""Get all currencies of a specific rarity"""
	return currencies_by_rarity.get(rarity, [])

func get_currencies_by_material(material: String) -> Array[CurrencyResource]:
	"""Get all currencies of a specific material"""
	return currencies_by_material.get(material, [])

func get_all_currencies() -> Dictionary:
	"""Get all currencies"""
	return currencies.duplicate()

func convert_currency(from_currency: String, to_currency: String, amount: int) -> int:
	"""Convert currency from one type to another"""
	if not currencies.has(from_currency) or not currencies.has(to_currency):
		return 0

	if from_currency == to_currency:
		return amount

	# Convert to copper first, then to target currency
	var copper_amount = amount * currencies[from_currency].value_base
	var target_amount = int(copper_amount / currencies[to_currency].value_base)

	return target_amount

func get_exchange_rate(from_currency: String, to_currency: String) -> float:
	"""Get exchange rate between two currencies"""
	if not exchange_rates.has(from_currency):
		return 0.0

	var rates = exchange_rates[from_currency]
	if not rates.has(to_currency):
		return 0.0

	return rates[to_currency]

func get_common_currencies() -> Array[CurrencyResource]:
	"""Get all common currencies"""
	return get_currencies_by_rarity("common")

func get_precious_metal_currencies() -> Array[CurrencyResource]:
	"""Get all currencies made of precious metals"""
	var precious = []
	for currency_id in currencies:
		var currency = currencies[currency_id]
		if currency.is_precious_metal():
			precious.append(currency)
	return precious
