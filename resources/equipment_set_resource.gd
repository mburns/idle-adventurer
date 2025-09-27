extends Resource

class_name EquipmentSetResource

# D&D Equipment Sets as a Godot Resource

@export var set_id: String = ""
@export var set_name: String = ""
@export var description: String = ""
@export var pieces: Array[String] = []  # Equipment piece IDs
@export var bonuses: Dictionary = {}  # Set bonuses
@export var rarity: String = "common"
@export var required_class: String = ""  # Optional class requirement
@export var required_level: int = 1  # Minimum level requirement

func get_set_bonuses() -> Dictionary:
	return bonuses.duplicate()

func get_piece_count() -> int:
	return pieces.size()

func has_piece(piece_id: String) -> bool:
	return piece_id in pieces

func get_rarity_color() -> Color:
	match rarity.to_lower():
		"common":
			return Color.WHITE
		"uncommon":
			return Color.GREEN
		"rare":
			return Color.BLUE
		"very rare":
			return Color.PURPLE
		"legendary":
			return Color.ORANGE
		"artifact":
			return Color.GOLD
		_:
			return Color.WHITE

func get_bonus_description() -> String:
	var descriptions = []
	for bonus_type in bonuses:
		var value = bonuses[bonus_type]
		if bonus_type == "armor_class":
			descriptions.append("+%d AC" % value)
		elif bonus_type == "stealth":
			descriptions.append("+%d Stealth" % value)
		elif bonus_type == "movement_speed":
			descriptions.append("+%d ft. movement" % value)
		elif bonus_type == "damage_resistance":
			descriptions.append("Resistance to %s" % value)
		elif bonus_type == "spell_save_dc":
			descriptions.append("+%d Spell Save DC" % value)
		elif bonus_type == "spell_attack_bonus":
			descriptions.append("+%d Spell Attack Bonus" % value)
		elif bonus_type == "lockpicking":
			descriptions.append("+%d Lockpicking" % value)
		elif bonus_type == "healing_power":
			descriptions.append("+%d Healing Power" % value)
		elif bonus_type == "divine_spell_bonus":
			descriptions.append("+%d Divine Spell Bonus" % value)
		else:
			descriptions.append("+%d %s" % [value, bonus_type.capitalize()])

	return ", ".join(descriptions)

func is_complete_set(equipped_pieces: Array[String]) -> bool:
	for piece in pieces:
		if not piece in equipped_pieces:
			return false
	return true

func get_missing_pieces(equipped_pieces: Array[String]) -> Array[String]:
	var missing = []
	for piece in pieces:
		if not piece in equipped_pieces:
			missing.append(piece)
	return missing

func get_completion_percentage(equipped_pieces: Array[String]) -> float:
	if pieces.is_empty():
		return 100.0

	var equipped_count = 0
	for piece in pieces:
		if piece in equipped_pieces:
			equipped_count += 1

	return (float(equipped_count) / float(pieces.size())) * 100.0
