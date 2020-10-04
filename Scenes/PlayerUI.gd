extends CanvasLayer


# Declare member variables here. Examples:
var HP_label;
var Mana_label;
var XP_label;
var Gold_label;
var Time_label;
var inventoryList = [];
var loopClock;

var chickenList = ["chickenA", "chickenB", "chickenC", "chickenD"];
var maxChickens = 4;

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up inventory slots 1-6
	for n in range(6):
		inventoryList.append(get_node("ColorRect/Item" + String(n+1)));
		
	# Grab label txt nodes
	HP_label = get_node("ColorRect/HP");
	Mana_label = get_node("ColorRect/Mana");
	XP_label = get_node("ColorRect/XP");
	Gold_label = get_node("ColorRect/Gold");
	Time_label = get_node("ColorRect/TimeLabel");
	
	# Reset time remaining in loop clock
	loopClock = 300;
	
	
func _process(delta):
	loopClock -= delta;
# warning-ignore:integer_division
	var str_elapsed = "%02d : %02d" % [int(loopClock) / 60, int(loopClock) % 60];
	Time_label.text = "Time Remaining in Loop\n" + str_elapsed;
	
	# Check if we are out of time or life
	if(loopClock <= 0 or int(HP_label.text) <= 0):
		playerLoses();


# Updates the name and image of the item in a given slot
func updateInventorySlot(slotNum, newLabel, newAnimation):
	inventoryList[slotNum].get_node("Label").text = newLabel;
	inventoryList[slotNum].animation = newAnimation;


# Update UI labels for player stats
func _on_Player_updatePlayerUI(HP, maxHP, Gold, XP):
	HP_label.text = "HP: " + String(HP);
	Mana_label.text = "MaxHP: " + String(maxHP);
	Gold_label.text = "Gold: " + String(Gold);
	XP_label.text = "XP: " + String(XP);


# See if we have the right chicken in inventory
func _on_Player_checkWinCondition():
	var chickenCount = 0;
	
	for item in inventoryList:
		print(item.get_node("Label").text)
		if(item.get_node("Label").text == "ChickenA" or item.get_node("Label").text == "ChickenB" or item.get_node("Label").text == "ChickenC" or item.get_node("Label").text == "ChickenD"):
			chickenCount += 1;

	if chickenCount >= maxChickens:
		playerWins();


func playerWins():
	get_tree().change_scene("res://Scenes/GameWin.tscn")

	
func playerLoses():
	get_tree().reload_current_scene();


# Add an item to inventory tracker
func _on_Player_addItemToInventory(item):
	# Find next empty pocket and put item in it
	for n in range(0, inventoryList.size()):
		if(inventoryList[n].get_node("Label").text == "Pocket"):
			inventoryList[n].get_node("Label").text = item.name;
			updateInventoryAppearance(item, n+1);
			break;


# Redraw inventory items
func updateInventoryAppearance(item, n):
	get_node("ColorRect/Item" + String(n) + "/Label").text = item.name;
	if("Chicken" in item.name):
		get_node("ColorRect/Item" + String(n)).animation = "chicken";
	elif("clover" in item.name):
		get_node("ColorRect/Item" + String(n)).animation = "clover";
	elif("boots" in item.name):
		get_node("ColorRect/Item" + String(n)).animation = "boots";
