extends KinematicBody2D

# Member variables
var gridSize = 32;
export (int) var speed = 100;
var facing_direction = "down";
var HP;
var Mana;
var XP;
var Gold;

var sfx_playerHurt;
var sfx_hogweed;

# Nodes
var playerRayCast;

# Signals
signal updatePlayerUI(HP, Mana, Gold, XP)

# Called when the node enters the scene tree for the first time.
func _ready():
	playerRayCast = get_node("RayCast2D");
	HP = 50;
	Mana = 10;
	XP = 0;
	Gold = 0;


# Called every physics tick
func _physics_process(delta):
	var collision = handlePlayerMovement(delta);
	
	if(collision != null):
		handleInterestingCollisions(collision);
	
	checkAction();
	updateStats();


# Check input and adjust player position
func handlePlayerMovement(delta):
	# Get player input
	var direction: Vector2;
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up");
	
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized();
	
	# Update facing if needed
	if(direction != Vector2.ZERO):
		updateRaycastFacing(direction);
	
	# Apply movement
	var movement = speed * direction * delta;
	return move_and_collide(movement);


# Adjust the cast_to of the players raycast (facing)
func updateRaycastFacing(direction):
	playerRayCast.set_cast_to(direction * gridSize);


func checkAction():
	if(Input.is_action_just_pressed("ui_accept")):
		playerRayCast.force_raycast_update();
		var whatWeHit = playerRayCast.get_collider();
		
		if(whatWeHit != null):
			if("NPC" in whatWeHit.name):
				whatWeHit.get_node("Polygon2D").visible = !whatWeHit.get_node("Polygon2D").visible 


# Send a signal to update player stats in UI
func updateStats():
	emit_signal("updatePlayerUI", HP, Mana, Gold, XP);


# If the player hit a monster or something, handle results
func handleInterestingCollisions(collision):
	# Most enemies will just exchange damage and drop loot
	var whatWeHit = collision.collider.name;
	
	if("Hogweed" in whatWeHit):
		HP -= 10;
		XP += 10;
		Gold += 5;
		# TODO: play sounds
		collision.collider.queue_free();
	elif("Gremlint" in whatWeHit):
		HP -= 15;
		XP += 5;
		Gold += 20;
		# TODO: play sounds
		collision.collider.queue_free();
	elif("Knight" in whatWeHit):
		HP -= 20;
		XP += 15;
		Gold += 15;
		# TODO: play sounds
		collision.collider.queue_free();
