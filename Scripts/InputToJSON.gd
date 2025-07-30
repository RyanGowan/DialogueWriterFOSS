extends Control

@onready var acceptBtn = $Background/Confirm/Buttons/Add;
@onready var clearBtn = $Background/Confirm/Buttons/Delete;
@onready var saveBtn = $Background/Output/Save;
@onready var dialogueOptionBtn = $Background/InputScroll/InputContainer/AddDialogueOption;

@onready var idField = $Background/InputScroll/InputContainer/IDInput;
@onready var nameField = $"Background/InputScroll/InputContainer/Name Input";
@onready var expressionField = $Background/InputScroll/InputContainer/ExpressionID;
@onready var dialogueField = $Background/InputScroll/InputContainer/DialogueEntry;
@onready var proceedField =  $Background/InputScroll/InputContainer/ProceedTo;

@onready var outputField = $Background/Output/CodeEdit;

var currentContent: String = "";
var currentEntries: Array = [];
var currentCharacters: Array = [];

func _ready():
	acceptBtn.button_down.connect(AddToFile);
	pass;
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
	
func ClearInputFields() -> void:
	dialogueField.text = "";
	idField.text = "";
	expressionField.text = "";
	nameField.text = "";
	proceedField.text = "";
	pass;
