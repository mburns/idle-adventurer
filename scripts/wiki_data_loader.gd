class_name WikiDataLoader
extends Resource

# Loads D&D data from the wiki markdown files

static func load_class_from_wiki(class_name: String) -> Dictionary:
	var file_path = "res://wiki/Classes/%s.md" % class_name.capitalize()
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Warning: Could not load class file: " + file_path)
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	return parse_class_markdown(content, class_name)

static func load_equipment_from_wiki() -> Dictionary:
	var equipment = {}
	
	# Load armor
	var armor_file = FileAccess.open("res://wiki/Equipment/Armor.md", FileAccess.READ)
	if armor_file:
		equipment["armor"] = parse_equipment_markdown(armor_file.get_as_text())
		armor_file.close()
	
	# Load weapons
	var weapons_file = FileAccess.open("res://wiki/Equipment/Weapons.md", FileAccess.READ)
	if weapons_file:
		equipment["weapons"] = parse_equipment_markdown(weapons_file.get_as_text())
		weapons_file.close()
	
	# Load other equipment
	var equipment_files = [
		"res://wiki/Equipment/Adventuring Gear.md",
		"res://wiki/Equipment/Tools.md",
		"res://wiki/Equipment/Coinage.md"
	]
	
	for file_path in equipment_files:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var category = file_path.get_file().get_basename().to_lower()
			equipment[category] = parse_equipment_markdown(file.get_as_text())
			file.close()
	
	return equipment

static func load_treasure_from_wiki() -> Dictionary:
	var treasure = {}
	var treasure_dir = DirAccess.open("res://wiki/Treasure/")
	if treasure_dir:
		for file_name in treasure_dir.get_files():
			if file_name.ends_with(".md"):
				var file_path = "res://wiki/Treasure/" + file_name
				var file = FileAccess.open(file_path, FileAccess.READ)
				if file:
					var item_name = file_name.get_basename()
					treasure[item_name] = parse_treasure_markdown(file.get_as_text())
					file.close()
	
	return treasure

static func load_spells_from_wiki() -> Dictionary:
	var spells = {}
	var spells_dir = DirAccess.open("res://wiki/Spells/")
	if spells_dir:
		for file_name in spells_dir.get_files():
			if file_name.ends_with(".md"):
				var file_path = "res://wiki/Spells/" + file_name
				var file = FileAccess.open(file_path, FileAccess.READ)
				if file:
					var spell_name = file_name.get_basename()
					spells[spell_name] = parse_spell_markdown(file.get_as_text())
					file.close()
	
	return spells

static func load_abilities_from_wiki() -> Dictionary:
	var abilities = {}
	var ability_files = [
		"res://wiki/Gameplay/Abilities/Strength.md",
		"res://wiki/Gameplay/Abilities/Dexterity.md",
		"res://wiki/Gameplay/Abilities/Constitution.md",
		"res://wiki/Gameplay/Abilities/Intelligence.md",
		"res://wiki/Gameplay/Abilities/Wisdom.md",
		"res://wiki/Gameplay/Abilities/Charisma.md"
	]
	
	for file_path in ability_files:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var ability_name = file_path.get_file().get_basename().to_lower()
			abilities[ability_name] = parse_ability_markdown(file.get_as_text())
			file.close()
	
	return abilities

# Parse class markdown content
static func parse_class_markdown(content: String, class_name: String) -> Dictionary:
	var lines = content.split("\n")
	var class_data = {
		"name": class_name,
		"hit_die": 8,
		"primary_ability": "strength",
		"saving_throws": [],
		"skill_choices": 2,
		"skill_options": [],
		"armor_proficiencies": [],
		"weapon_proficiencies": [],
		"tool_proficiencies": [],
		"starting_equipment": {},
		"features": []
	}
	
	var current_section = ""
	
	for line in lines:
		line = line.strip_edges()
		
		if line.begins_with("### "):
			current_section = line.substr(4).to_lower()
		elif line.begins_with("**Hit Dice:**"):
			var hit_dice_text = line.split(":")[1].strip_edges()
			class_data.hit_die = extract_hit_die(hit_dice_text)
		elif line.begins_with("**Saving Throws:**"):
			var saves_text = line.split(":")[1].strip_edges()
			class_data.saving_throws = parse_saving_throws(saves_text)
		elif line.begins_with("**Skills:**"):
			var skills_text = line.split(":")[1].strip_edges()
			class_data.skill_options = parse_skill_options(skills_text)
		elif line.begins_with("**Armor:**"):
			var armor_text = line.split(":")[1].strip_edges()
			class_data.armor_proficiencies = parse_proficiencies(armor_text)
		elif line.begins_with("**Weapons:**"):
			var weapons_text = line.split(":")[1].strip_edges()
			class_data.weapon_proficiencies = parse_proficiencies(weapons_text)
		elif line.begins_with("**Tools:**"):
			var tools_text = line.split(":")[1].strip_edges()
			class_data.tool_proficiencies = parse_proficiencies(tools_text)
		elif current_section == "equipment" and line.begins_with("-"):
			# Parse starting equipment
			pass  # TODO: Implement equipment parsing
	
	return class_data

# Parse equipment markdown content
static func parse_equipment_markdown(content: String) -> Array[Dictionary]:
	var equipment = []
	var lines = content.split("\n")
	
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("|") and not line.begins_with("|---"):
			var parts = line.split("|")
			if parts.size() >= 3:
				var item = {
					"name": parts[1].strip_edges(),
					"cost": parts[2].strip_edges() if parts.size() > 2 else "",
					"weight": parts[3].strip_edges() if parts.size() > 3 else "",
					"description": parts[4].strip_edges() if parts.size() > 4 else ""
				}
				equipment.append(item)
	
	return equipment

# Parse treasure markdown content
static func parse_treasure_markdown(content: String) -> Dictionary:
	var treasure = {
		"name": "",
		"type": "wondrous item",
		"rarity": "common",
		"description": "",
		"properties": []
	}
	
	var lines = content.split("\n")
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("# "):
			treasure.name = line.substr(2)
		elif line.begins_with("**Type:**"):
			treasure.type = line.split(":")[1].strip_edges()
		elif line.begins_with("**Rarity:**"):
			treasure.rarity = line.split(":")[1].strip_edges()
		elif line.begins_with("- "):
			treasure.properties.append(line.substr(2))
		elif line != "" and not line.begins_with("#") and not line.begins_with("**"):
			treasure.description += line + " "
	
	return treasure

# Parse spell markdown content
static func parse_spell_markdown(content: String) -> Dictionary:
	var spell = {
		"name": "",
		"level": 0,
		"school": "evocation",
		"casting_time": "1 action",
		"range": "60 feet",
		"components": "V, S",
		"duration": "instantaneous",
		"description": ""
	}
	
	var lines = content.split("\n")
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("# "):
			spell.name = line.substr(2)
		elif line.begins_with("**Level:**"):
			spell.level = int(line.split(":")[1].strip_edges())
		elif line.begins_with("**School:**"):
			spell.school = line.split(":")[1].strip_edges()
		elif line.begins_with("**Casting Time:**"):
			spell.casting_time = line.split(":")[1].strip_edges()
		elif line.begins_with("**Range:**"):
			spell.range = line.split(":")[1].strip_edges()
		elif line.begins_with("**Components:**"):
			spell.components = line.split(":")[1].strip_edges()
		elif line.begins_with("**Duration:**"):
			spell.duration = line.split(":")[1].strip_edges()
		elif line != "" and not line.begins_with("#") and not line.begins_with("**"):
			spell.description += line + " "
	
	return spell

# Parse ability markdown content
static func parse_ability_markdown(content: String) -> Dictionary:
	var ability = {
		"name": "",
		"description": "",
		"skills": []
	}
	
	var lines = content.split("\n")
	var current_section = ""
	
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("### "):
			ability.name = line.substr(4)
		elif line.begins_with("***") and line.ends_with("***"):
			# Skill name
			var skill_name = line.replace("*", "").strip_edges()
			ability.skills.append(skill_name)
		elif line != "" and not line.begins_with("#") and not line.begins_with("**"):
			ability.description += line + " "
	
	return ability

# Helper functions
static func extract_hit_die(text: String) -> int:
	var regex = RegEx.new()
	regex.compile("(\\d+)d(\\d+)")
	var result = regex.search(text)
	if result:
		return int(result.get_string(2))
	return 8

static func parse_saving_throws(text: String) -> Array[String]:
	var saves = []
	var parts = text.split(",")
	for part in parts:
		saves.append(part.strip_edges().capitalize())
	return saves

static func parse_skill_options(text: String) -> Array[String]:
	var skills = []
	var parts = text.split(",")
	for part in parts:
		skills.append(part.strip_edges())
	return skills

static func parse_proficiencies(text: String) -> Array[String]:
	var proficiencies = []
	var parts = text.split(",")
	for part in parts:
		proficiencies.append(part.strip_edges())
	return proficiencies
