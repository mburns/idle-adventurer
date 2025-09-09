extends Control

var settings_data = {
	"idle_speed": 1.0,
	"auto_save": true,
	"notifications": true,
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"ui_scale": 1.0,
	"fullscreen": false
}

func _ready():
	load_settings()
	update_ui()

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
	%IdleSpeedSlider.value = settings_data.idle_speed
	%IdleSpeedValue.text = "%.1fx" % settings_data.idle_speed
	
	%AutoSaveCheckBox.button_pressed = settings_data.auto_save
	%NotificationsCheckBox.button_pressed = settings_data.notifications
	
	%MasterVolumeSlider.value = settings_data.master_volume
	%MasterVolumeValue.text = "%d%%" % (settings_data.master_volume * 100)
	
	%MusicVolumeSlider.value = settings_data.music_volume
	%MusicVolumeValue.text = "%d%%" % (settings_data.music_volume * 100)
	
	%SFXVolumeSlider.value = settings_data.sfx_volume
	%SFXVolumeValue.text = "%d%%" % (settings_data.sfx_volume * 100)
	
	%UIScaleSlider.value = settings_data.ui_scale
	%UIScaleValue.text = "%d%%" % (settings_data.ui_scale * 100)
	
	%FullscreenCheckBox.button_pressed = settings_data.fullscreen

func _on_idle_speed_changed(value: float):
	settings_data.idle_speed = value
	%IdleSpeedValue.text = "%.1fx" % value

func _on_master_volume_changed(value: float):
	settings_data.master_volume = value
	%MasterVolumeValue.text = "%d%%" % (value * 100)
	# Apply volume change immediately
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_volume_changed(value: float):
	settings_data.music_volume = value
	%MusicVolumeValue.text = "%d%%" % (value * 100)
	# Apply volume change immediately
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_volume_changed(value: float):
	settings_data.sfx_volume = value
	%SFXVolumeValue.text = "%d%%" % (value * 100)
	# Apply volume change immediately
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_ui_scale_changed(value: float):
	settings_data.ui_scale = value
	%UIScaleValue.text = "%d%%" % (value * 100)
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
	get_tree().change_scene_to_file("res://main.tscn")
