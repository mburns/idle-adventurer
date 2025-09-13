extends Control

var settings_data = {
	"theme": "default",
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 0.9,
	"ui_scale": 1.0,
	"fullscreen": false
}

func _ready():
	# Apply theme
	ThemeManager.apply_theme_to_children(self)

	load_settings()
	update_ui()
	setup_theme_options()

func load_settings():
	# Load settings from file
	var settings_file = FileAccess.open("user://settings.dat", FileAccess.READ)
	if settings_file:
		var json_string = settings_file.get_as_text()
		settings_file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			if data is Dictionary:
				settings_data.merge(data)

func save_settings():
	# Save settings to file
	var settings_file = FileAccess.open("user://settings.dat", FileAccess.WRITE)
	if settings_file:
		settings_file.store_string(JSON.stringify(settings_data))
		settings_file.close()
		print("Settings saved")

func update_ui():
	# Update UI elements with current settings
	var master_slider = %MasterVolumeSlider
	var music_slider = %MusicVolumeSlider
	var sfx_slider = %SFXVolumeSlider

	if master_slider:
		master_slider.value = settings_data.master_volume * 100
	else:
		print("Warning: MasterVolumeSlider not found in settings screen")

	if music_slider:
		music_slider.value = settings_data.music_volume * 100
	else:
		print("Warning: MusicVolumeSlider not found in settings screen")

	if sfx_slider:
		sfx_slider.value = settings_data.sfx_volume * 100
	else:
		print("Warning: SFXVolumeSlider not found in settings screen")

	# Set theme selection
	var themes = ThemeManager.get_available_themes()
	var theme_button = %ThemeOptionButton
	if theme_button:
		for i in range(themes.size()):
			if themes[i] == settings_data.theme:
				theme_button.selected = i
				break
	else:
		print("Warning: ThemeOptionButton not found in settings screen")

func setup_theme_options():
	"""Setup theme selection dropdown"""
	var themes = ThemeManager.get_available_themes()
	var theme_button = %ThemeOptionButton
	if theme_button:
		theme_button.clear()
		for theme_name in themes:
			theme_button.add_item(theme_name.capitalize())
	else:
		print("Warning: ThemeOptionButton not found in settings screen")

func _on_idle_speed_changed(value: float):
	settings_data.idle_speed = value
	var idle_speed_value = %IdleSpeedValue
	if idle_speed_value:
		idle_speed_value.text = "%.1fx" % value
	else:
		print("Warning: IdleSpeedValue not found in settings screen")

func _on_master_volume_changed(value: float):
	settings_data.master_volume = value
	var master_volume_value = %MasterVolumeValue
	if master_volume_value:
		master_volume_value.text = "%d%%" % (value * 100)
	else:
		print("Warning: MasterVolumeValue not found in settings screen")
	# Apply volume change immediately
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_volume_changed(value: float):
	settings_data.music_volume = value
	var music_volume_value = %MusicVolumeValue
	if music_volume_value:
		music_volume_value.text = "%d%%" % (value * 100)
	else:
		print("Warning: MusicVolumeValue not found in settings screen")
	# Apply volume change immediately
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_volume_changed(value: float):
	settings_data.sfx_volume = value
	var sfx_volume_value = %SFXVolumeValue
	if sfx_volume_value:
		sfx_volume_value.text = "%d%%" % (value * 100)
	else:
		print("Warning: SFXVolumeValue not found in settings screen")
	# Apply volume change immediately
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_ui_scale_changed(value: float):
	settings_data.ui_scale = value
	var ui_scale_value = %UIScaleValue
	if ui_scale_value:
		ui_scale_value.text = "%d%%" % (value * 100)
	else:
		print("Warning: UIScaleValue not found in settings screen")
	# Apply UI scale change immediately
	get_viewport().content_scale_factor = value

func _on_reset_button_pressed():
	# Reset to default settings
	settings_data = {
		"idle_speed": 1.0,
		"auto_save": true,
		"notifications": true,
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"ui_scale": 1.0,
		"fullscreen": false
	}
	update_ui()

func _on_save_button_pressed():
	save_settings()
	print("Settings saved successfully!")

func _on_back_button_pressed():
	# Save settings before going back
	save_settings()
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

func _on_apply_button_pressed():
	# Apply current settings
	save_settings()
	print("Settings applied successfully!")

func _on_theme_selected(index: int):
	"""Handle theme selection change"""
	var themes = ThemeManager.get_available_themes()
	if index < themes.size():
		settings_data.theme = themes[index]
		ThemeManager.apply_theme(themes[index])
		print("Theme changed to: " + themes[index])
