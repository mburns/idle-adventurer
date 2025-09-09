extends Control

var character: Character
var character_manager: CharacterManager
var activity_log: Array[String] = []
var achievements: Array[String] = []

func _ready():
	# Get character manager and current character
	character_manager = CharacterManager.new()
	character = character_manager.get_current_character()
	
	if character == null:
		print("Error: No character found")
		return
	
	# Load journal data
	load_journal_data()
	update_ui()

func load_journal_data():
	# Load activity log from save file
	var save_file = FileAccess.open("user://journal_save.dat", FileAccess.READ)
	if save_file:
		var json_string = save_file.get_as_text()
		save_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			activity_log = data.get("activity_log", [])
			achievements = data.get("achievements", [])

func save_journal_data():
	# Save journal data to file
	var data = {
		"activity_log": activity_log,
		"achievements": achievements
	}
	
	var save_file = FileAccess.open("user://journal_save.dat", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(data))
		save_file.close()

func add_activity_log_entry(entry: String):
	var timestamp = Time.get_datetime_string_from_system()
	activity_log.append("[%s] %s" % [timestamp, entry])
	
	# Keep only last 100 entries
	if activity_log.size() > 100:
		activity_log.pop_front()
	
	save_journal_data()
	update_ui()

func add_achievement(achievement: String):
	if not achievements.has(achievement):
		achievements.append(achievement)
		add_activity_log_entry("Achievement unlocked: " + achievement)
		save_journal_data()
		update_ui()

func update_ui():
	if character == null:
		return
	
	# Update activity log
	update_activity_log()
	
	# Update achievements
	update_achievements()
	
	# Update statistics
	update_statistics()

func update_activity_log():
	var log_text = ""
	if activity_log.size() > 0:
		for entry in activity_log:
			log_text += entry + "\n"
	else:
		log_text = "No activities recorded yet."
	
	%ActivityLog.text = log_text

func update_achievements():
	var achievements_text = ""
	if achievements.size() > 0:
		for achievement in achievements:
			achievements_text += "[color=yellow]★[/color] " + achievement + "\n"
	else:
		achievements_text = "No achievements unlocked yet."
	
	%AchievementsList.text = achievements_text

func update_statistics():
	var stats_text = ""
	stats_text += "Character: %s\n" % character.get_summary()
	stats_text += "Gold: %d\n" % character.gold
	stats_text += "Experience: %d\n" % character.experience_points
	stats_text += "Hit Points: %d/%d\n" % [character.hit_points, character.max_hit_points]
	stats_text += "Armor Class: %d\n" % character.armor_class
	stats_text += "Proficiency Bonus: %+d\n" % character.proficiency_bonus
	
	# Add activity statistics
	stats_text += "\nActivity Statistics:\n"
	stats_text += "Activities Completed: %d\n" % activity_log.size()
	stats_text += "Achievements Unlocked: %d\n" % achievements.size()
	
	%StatisticsList.text = stats_text

func _on_back_button_pressed():
	# Save notes before going back
	save_journal_data()
	get_tree().change_scene_to_file("res://main.tscn")

# Called when the game needs to log an activity
func log_activity(activity_name: String, rewards: Dictionary):
	var entry = "Completed %s" % activity_name
	if rewards.xp > 0:
		entry += " (+%d XP)" % rewards.xp
	if rewards.gold > 0:
		entry += " (+%d gold)" % rewards.gold
	
	add_activity_log_entry(entry)
	
	# Check for achievements
	check_achievements()

func check_achievements():
	# Check for various achievements
	if character.level >= 2 and not achievements.has("First Level Up"):
		add_achievement("First Level Up")
	
	if character.gold >= 100 and not achievements.has("Wealthy"):
		add_achievement("Wealthy")
	
	if character.gold >= 1000 and not achievements.has("Rich"):
		add_achievement("Rich")
	
	if activity_log.size() >= 10 and not achievements.has("Active"):
		add_achievement("Active")
	
	if activity_log.size() >= 50 and not achievements.has("Very Active"):
		add_achievement("Very Active")
	
	if activity_log.size() >= 100 and not achievements.has("Extremely Active"):
		add_achievement("Extremely Active")
