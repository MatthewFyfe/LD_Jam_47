extends KinematicBody2D

# Member variables
var gridSize = 32;
export (int) var speed = 100;
var facing_direction = "down";
var maxHP;
var HP;
var XP;
var Gold;
var cloverToggle = false;
var rng = RandomNumberGenerator.new()

var sfx_playerHurt;
var sfx_hogweed;
var sfx_gremlint;
var sfx_knight;
var sfx_item;
var sfx_chicken;

# Nodes
var playerRayCast;
var audio;

# Signals
signal updatePlayerUI(HP, Mana, Gold, XP);
signal checkWinCondition();
signal addItemToInventory();

# Called when the node enters the scene tree for the first time.
func _ready():
	playerRayCast = get_node("RayCast2D");
	audio = get_node("AudioStreamPlayer")
	HP = 50;
	maxHP = 50;
	XP = 0;
	Gold = 0;
	rng.randomize();
	
	# Set up SFX
	sfx_playerHurt = load("res://SFX/damage.wav");
	sfx_gremlint = load ("res://SFX/gremlint.wav");
	sfx_chicken = load("res://SFX/chicken.wav");
	sfx_item = load("res://SFX/item.wav");
	sfx_knight = load("res://SFX/knight.wav");
	sfx_hogweed = load("res://SFX/hogweed.wav");
	

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
				# Open NPC text box
				whatWeHit.get_node("Polygon2D").visible = !whatWeHit.get_node("Polygon2D").visible
			elif("Chicken" in whatWeHit.name):
				# Pick up the chicken
				addItemToInventory(whatWeHit);
				whatWeHit.queue_free();
				audio.set_stream(sfx_chicken);
				audio.volume_db = 0;
				audio.play();
			elif("clover" in whatWeHit.name):
				# Pick up lucky clover
				cloverToggle = true;
				addItemToInventory(whatWeHit);
				audio.set_stream(sfx_item);
				audio.volume_db = 0;
				audio.play();
				whatWeHit.queue_free();
			elif("boots" in whatWeHit.name):
				# Pick up magic boots
				speed = speed * 2;
				addItemToInventory(whatWeHit);
				audio.set_stream(sfx_item);
				audio.volume_db = 0;
				audio.play();
				whatWeHit.queue_free();


# Send a signal to update player stats in UI
func updateStats():
	emit_signal("updatePlayerUI", HP, maxHP, Gold, XP);


# If the player hit a monster or something, handle results
func handleInterestingCollisions(collision):
	# Most enemies will just exchange damage and drop loot
	var whatWeHit = collision.collider.name;
	var takeDamage = true;
	
	if(cloverToggle == true):
		var ranNum = rng.randf();
		if(ranNum >= 0.2):
			takeDamage = false;
		
	
	if("Hogweed" in whatWeHit):
		if(takeDamage):
			HP -= 10;
		XP += 10;
		Gold += 5;
		# TODO: play sounds
		audio.set_stream(sfx_hogweed);
		audio.play();
		audio.volume_db = 0;
		collision.collider.queue_free();
	elif("Gremlint" in whatWeHit):
		if(takeDamage):
			HP -= 15;
		XP += 5;
		Gold += 20;
		# TODO: play sounds
		audio.set_stream(sfx_gremlint);
		audio.volume_db = -10;
		audio.play();
		collision.collider.queue_free();
	elif("Knight" in whatWeHit):
		if(takeDamage):
			HP -= 20;
		XP += 15;
		Gold += 15;
		# TODO: play sounds
		audio.set_stream(sfx_knight);
		audio.volume_db = -1;
		audio.play();
		collision.collider.queue_free();
	elif("Priest" in whatWeHit):
		if(HP < maxHP && Gold > 0):
			Gold -= 1;
			HP += 1;
	elif("Trainer" in whatWeHit):
		if(XP > 0):
			XP -= 1;
			maxHP += 1;
	elif("TimeEgg" in whatWeHit):
		emit_signal("checkWinCondition");


func addItemToInventory(item):
	emit_signal("addItemToInventory", item);
