extends Button

var mainMenuPath = "res://Scenes/MainMenu.tscn";

func _ready():
	button_down.connect(ReturnToMenu);
	pass;
	
func ReturnToMenu() -> void:
	get_tree().change_scene_to_file(mainMenuPath);
	pass;
