extends Control

#region Buttons
@onready var acceptBtn = $Background/Confirm/Buttons/Add;
@onready var clearBtn = $Background/Confirm/Buttons/Delete;
@onready var saveBtn = $Background/Output/Save;
@onready var loadBtn = $Background/Output/Load;
@onready var dialogueOptionBtn = $Background/InputScroll/InputContainer/DialogueOptions/AddDialogueOption;
@onready var newFileBtn = $Background/Output/New;
#endregion

#region input fields
@onready var idField = $"Background/InputScroll/InputContainer/ID&Proceeds/ID/IDInput";
@onready var nameField = $"Background/InputScroll/InputContainer/Name&Expression/Name/Name Input";
@onready var expressionField = $"Background/InputScroll/InputContainer/Name&Expression/Expression/ExpressionID";
@onready var dialogueField = $Background/InputScroll/InputContainer/DialogueEntry;
@onready var proceedField =  $"Background/InputScroll/InputContainer/ID&Proceeds/ProceedID/ProceedTo";
@onready var alignmentField = $Background/InputScroll/InputContainer/AlignmentUI/AlignmentEntry;
#endregion

@onready var optionList = $Background/InputScroll/InputContainer/DialogueOptions/List;
var currentDialogueOptions = [];

#region UI Groupings
@onready var dialogueOptionUI = $Background/InputScroll/InputContainer/DialogueOptions;
@onready var nameUI = $"Background/InputScroll/InputContainer/Name&Expression/Name";
@onready var expressionUI = $"Background/InputScroll/InputContainer/Name&Expression/Expression";
@onready var idUI = $"Background/InputScroll/InputContainer/ID&Proceeds/ID";
@onready var proceedUI = $"Background/InputScroll/InputContainer/ID&Proceeds/ProceedID";
@onready var alignmentUI = $Background/InputScroll/InputContainer/AlignmentUI;
#endregion

#region Output
@onready var outputField = $Background/Output/CodeEdit;
@onready var saveFileDialog = $Background/SaveFileDialog;
@onready var loadFileDialog = $Background/LoadFileDialog;
#endregion

var fileDialogPath: String = "";

var currentEntries: Dictionary = {};
var currentCharacters: Array = [];

#var test: Dictionary = {"1": {"aa": "bb"}};

func _ready():
	acceptBtn.button_down.connect(AddToFile);
	clearBtn.button_down.connect(ClearInputFields);
	saveBtn.button_down.connect(SaveCurrentJSON);
	loadBtn.button_down.connect(LoadDialogueFile);
	newFileBtn.button_down.connect(StartNewFile);
	dialogueOptionBtn.button_down.connect(AddDialogueOption);
	DoSettingsAdjustments();
	pass;
	
func DoSettingsAdjustments() -> void:
	nameUI.visible = Settings.namesEnabled;
	outputField.visible = Settings.codeEditorEnabled;
	dialogueOptionUI.visible = Settings.dialogueOptionsEnabled;
	expressionUI.visible = Settings.expressionEnabled;
	idUI.visible = Settings.idEnabled;
	proceedUI.visible = Settings.proceedEnabled;
	alignmentUI.visible = Settings.alignmentEnabled;
	pass;

#region Add Entry Functions
#returns a string representing which characters are present in the current dialogue file
func UpdatePresentCharacters() -> String:
	var returnVal = "";
	var startLine = str("\"", "PresentCharacters", "\"", ":[\n");
	returnVal = startLine;
	for x in len(currentCharacters):
		var character = str("\t\"", currentCharacters[x], "\"");
		if x < len(currentCharacters) - 1:
			#only add a comma and a new line if there is another character coming
			character = str(character, ",\n");
		returnVal = str(returnVal, character);
		pass;
	returnVal = str(returnVal, "\n\t],",);
	return returnVal;

#retrieves what state the output field
func GetCurrentOutputFieldState() -> void:
	
	var stringToParse = outputField.text
	var data = JSON.parse_string(stringToParse);
	if data == null:
		return;
	var dialogueScript = data["Script"];
	var characters = data["PresentCharacters"];
	
	for x in dialogueScript.keys():
		#print(currentEntries[x]);
		currentEntries[x] = dialogueScript[x];
		if not(currentEntries[x]["character"] in currentCharacters):
			currentCharacters.append(currentEntries[x]["character"]);
			pass;
		pass;
	pass;

#adds the current contents of the input fields to the JSON file
func AddToFile() -> void:
	#if this current name is not already in our charater list, add it
	if not(nameField.text in currentCharacters):
		currentCharacters.append(nameField.text);
		pass;
	
	#generate a dictionary entry
	var pair: Dictionary = GenerateEntry();
	
	currentEntries.merge(pair);
	var openingLine = "{"
	var presentCharacters = UpdatePresentCharacters();
	var entryKeys = currentEntries.keys();
	var mainEntries = "\"Script\":{\n";
	
	for x in len(entryKeys):
		var key = str("\"",entryKeys[x], "\"", ":");
		mainEntries = str(mainEntries, "\t\t", key, JSON.stringify(currentEntries[entryKeys[x]]));
		if x < len(currentEntries) - 1:
			#only add a comma and a new line if there is another character coming
			mainEntries = str(mainEntries, ",\n");
		else:
			mainEntries = str(mainEntries, "\n");
	var endLine = "\t}\n}";
	#print(mainEntries);
	var finalResult = str(openingLine, "\n\t", presentCharacters, "\n\t", mainEntries, endLine);
	outputField.text = finalResult;
	ClearInputFields();

#generates a JSON entry from the data in the input fields
func GenerateEntry() -> Dictionary:
	
	var finalDict: Dictionary = {};
	var subDictionary: Dictionary = {};
	var finalString = "";
	
	
	var idLine = str(idField.text);
	if dialogueField.text != "":
		subDictionary["speech"] = dialogueField.text;
	if expressionField.text != "":
		subDictionary["expression"] = expressionField.text;
	if nameField.text != "":
		subDictionary["character"] = nameField.text;
	if proceedField.text != "":
		subDictionary["proceedsTo"] = proceedField.text;
	if alignmentField.text != "":
		subDictionary["alignment"] = alignmentField.text;
	
	#if there are dialogue option fields, add them here
	var txtArray = [];
	for x in len(currentDialogueOptions):
		txtArray.append(currentDialogueOptions[x].text);
	if txtArray.size() > 0:
		subDictionary["dialogueOptions"] = txtArray;
	
	
	finalDict[idLine] = subDictionary
	return finalDict;
	
#endregion

#region Save & Load Functions
func SaveCurrentJSON() -> void:
	saveFileDialog.show();
	pass;
	
func LoadDialogueFile() -> void:
	loadFileDialog.show();
	pass;

#event response functions rigged up to the save and load file dialogs, let us read and write to file
func _on_save_file_dialog_file_selected(path):
	fileDialogPath = path;
	pass

	
func _on_save_file_dialog_confirmed():
	var file = FileAccess.open(fileDialogPath, FileAccess.WRITE)
	file.store_string(outputField.text);
	file.close();
	pass;
	
func _on_load_file_dialog_file_selected(path):
	fileDialogPath = path;
	
func _on_load_file_dialog_confirmed():
	var file = FileAccess.open(fileDialogPath, FileAccess.READ);
	outputField.text = file.get_as_text();
	file.close();
	GetCurrentOutputFieldState();
	pass
#endregion

func AddDialogueOption() -> void:
	var newOption = TextEdit.new();
	newOption.custom_minimum_size = Vector2(0, 35);
	newOption.placeholder_text = "Dialogue Option Goes Here"
	optionList.add_child(newOption);
	currentDialogueOptions.append(newOption);
	pass;

func ClearDialogueOptions() -> void:
	for x in currentDialogueOptions:
		x.queue_free();
	
	currentDialogueOptions.clear();
	pass;

func StartNewFile() -> void:
	ClearInputFields();
	currentEntries.clear();
	outputField.text = "";
	pass;

#resets all input fields to empty strings
func ClearInputFields() -> void:
	dialogueField.text = "";
	idField.text = "";
	expressionField.text = "";
	nameField.text = "";
	proceedField.text = "";
	ClearDialogueOptions();
	pass;
