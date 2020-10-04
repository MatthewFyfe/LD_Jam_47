extends KinematicBody2D


# Declare member variables here. Examples:
var textLabel;
export (String) var npcText = "Hello!";


# Called when the node enters the scene tree for the first time.
func _ready():
	textLabel = get_node("Polygon2D/Label");
	textLabel.text = npcText;
