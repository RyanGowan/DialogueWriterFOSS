extends Control

@export var settingName = "Default";
@export var settingVariableName = "";

@onready var settingToggle = $CheckBox;
@onready var settingLabel = $Label;

func _ready():
	settingLabel.text = settingName;
	settingToggle.button_pressed = GetCurrentSettingValue();
	settingToggle.toggled.connect(SetCurrentSettingValue);
	pass;
	
func GetCurrentSettingValue() -> bool:
	return Settings.get(settingVariableName);
	
func SetCurrentSettingValue(toggleValue) -> void:
	Settings.set(settingVariableName, toggleValue);
	pass;
