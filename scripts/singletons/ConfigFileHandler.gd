extends Node

var pad : bool = true

var config = ConfigFile.new()
const SETTING_FILE_PATH = "user://settings.ini"

func _ready() -> void:
	#print(OS.get_data_dir())
	if !FileAccess.file_exists(SETTING_FILE_PATH):
		#video
		config.set_value('video','fullscreen',false)
		
		#audio
		config.set_value('audio','volume',1.0)
		config.set_value('audio','volumeFX',1.0)
		config.set_value('audio','volumeMusic',1.0)
		
		#control
		config.set_value('control','invertX',false)
		config.set_value('control','invertY',false)
		
		config.save(SETTING_FILE_PATH)
		
	else :
		config.load(SETTING_FILE_PATH)
		
		
func apply_video_settings():
	var video_setting = ConfigFileHandler.load_video_settings()
	if video_setting.fullscreen :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)		
	else :
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)	
		
func save_video_setting(key:String, value):
	config.set_value('video',key,value)
	config.save(SETTING_FILE_PATH)
	
func load_video_settings():
	var video_settings={}
	for key in config.get_section_keys('video'):
		video_settings[key]=config.get_value("video", key)
	return video_settings
	
func save_control_setting(key:String, value):
	config.set_value('control',key,value)
	config.save(SETTING_FILE_PATH)
	
func load_control_settings():
	var control_settings={}
	for key in config.get_section_keys('control'):
		control_settings[key]=config.get_value("control", key)
	return control_settings
