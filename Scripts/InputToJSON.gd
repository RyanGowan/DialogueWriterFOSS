extends Control

@onready var acceptBtn = $Background/Confirm/Buttons/Add;
@onready var clearBtn = $Background/Confirm/Buttons/Delete;
@onready var saveBtn = $Background/Output/Save;
@onready var loadBtn = $Background/Output/Load;
@onready var dialogueOptionBtn = $Background/InputScroll/InputContainer/AddDialogueOption;

@onready var idField = $Background/InputScroll/InputContainer/IDInput;
@onready var nameField = $"Background/InputScroll/InputContainer/Name Input";
@onready var expressionField = $Background/InputScroll/InputContainer/ExpressionID;
@onready var dialogueField = $Background/InputScroll/InputContainer/DialogueEntry;
@onready var proceedField =  $Background/InputScroll/InputContainer/ProceedTo;

@onready var outputField = $Background/Output/CodeEdit;

@onready var saveFileDialog = $Background/SaveFileDialog;
@onready var loadFileDialog = $Background/LoadFileDialog;

var fileDialogPath: String = "";

var currentContent: String = "";
var currentEntries: Array = [];
var currentCharacters: Array = [];

func _ready():
	acceptBtn.button_down.connect(AddToFile);
	clearBtn.button_down.connect(ClearInputFields);
	saveBtn.button_down.connect(SaveCurrentJSON);
	loadBtn.button_down.connect(LoadDialogueFile);
	pass;

#region Add Entry Functions
#returns a string representing which characters are present in the current dialogue file
func UpdatePresentCharacters() -> String:
	var returnVal = "";
	var startLine = str("\"", "PresentCharacters", "\"", ":[");
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

#adds the current contents of the input fields to the JSON file
func AddToFile() -> void:
	var entry: String = GenerateEntry();
	currentEntries.append(entry);
	var openingLine = "{"
	var presentCharacters = UpdatePresentCharacters();
	var mainEntries = "\"Script\":{\n";
	for x in len(currentEntries):
		mainEntries = str(mainEntries, "\t", currentEntries[x])
		if x < len(currentEntries) - 1:
			#only add a comma and a new line if there is another character coming
			mainEntries = str(mainEntries, ",\n");
		else:
			mainEntries = str(mainEntries, "\n");
		pass;
	var endLine = "\t}\n}";
	
	var finalResult = str(openingLine, "\n\t", presentCharacters, "\n\t", mainEntries, endLine);
	outputField.text = finalResult;
	ClearInputFields();

#generates a JSON entry from the data in the input fields
func GenerateEntry() -> String:
	
	var finalString = "";
	var idLine = str("\t\"", idField.text, "\"", ":{");
	var dialogueLine = str("\t\t\"", "speech" , "\"", ":", "\"", dialogueField.text, "\"", ",");
	var expressionLine = str("\t\t\"", "expression" , "\"", ":", "\"", expressionField.text, "\"", ",");
	var nameLine = str("\t\t\"", "character" , "\"", ":", "\"", nameField.text, "\"", ",");
	var proceedingLine = str("\t\t\"", "proceedsTo" , "\"", ":", "\"", proceedField.text, "\"",);
	var endingLine = str("\t\t}");
	
	finalString = str(idLine, "\n", dialogueLine, "\n", expressionLine, "\n", nameLine, "\n");
	if proceedField.text != "":
		finalString = str(finalString, proceedingLine, "\n");
	finalString = str(finalString, endingLine);
	
	return finalString;
	
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
	pass
#endregion

#resets all input fields to empty strings
func ClearInputFields() -> void:
	dialogueField.text = "";
	idField.text = "";
	expressionField.text = "";
	nameField.text = "";
	proceedField.text = "";
	pass;
