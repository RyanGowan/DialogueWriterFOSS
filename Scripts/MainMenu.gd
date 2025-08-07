extends Control

#hard coding scene paths to change to kinda sucks, but the app is small enough so this shcould be acceptable
var writerScenePath = "res://Scenes/Writer.tscn";
var settingsScenePath = "res://Scenes/SettingsMenu.tscn";

@onready var startBtn = $Background/VBoxContainer/Start;
@onready var settingsBtn = $Background/VBoxContainer/Settings;

func _ready():
	startBtn.button_down.connect(GoToWriter);
	settingsBtn.button_down.connect(GoToSettings);
	pass;
	
func GoToWriter() -> void:
	get_tree().change_scene_to_file(writerScenePath);
	pass;
	
func GoToSettings() -> void:
	get_tree().change_scene_to_file(settingsScenePath);
	pass;
