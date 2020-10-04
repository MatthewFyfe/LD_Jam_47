extends CanvasLayer


# Declare member variables here. Examples:
var HP_label;
var Mana_label;
var XP_label;
var Gold_label;
var Time_label;
var inventoryList = [];
var loopClock;


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
	
	# Check if we are out of time
	if(loopClock <= 0):
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene();


# Updates the name and image of the item in a given slot
func updateInventorySlot(slotNum, newLabel, newAnimation):
	inventoryList[slotNum].get_node("Label").text = newLabel;
	inventoryList[slotNum].animation = newAnimation;


# Update UI labels for player stats
func _on_Player_updatePlayerUI(HP, Mana, Gold, XP):
	HP_label.text = "HP: " + String(HP);
	Mana_label.text = "Mana: " + String(Mana);
	Gold_label.text = "Gold: " + String(Gold);
	XP_label.text = "XP: " + String(XP);
