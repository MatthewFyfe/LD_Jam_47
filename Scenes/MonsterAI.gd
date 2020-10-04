extends KinematicBody2D


# Declare member variables here. Examples:
var rng = RandomNumberGenerator.new()
var wanderDuration = 0
var direction: Vector2
var movement
export var speed = 80;
export (String) var monsterType = "Hogweed";
export (int) var monsterViewRange = 160;
var stateMachineStatus = "idle";

# Nodes
var player;
var viewRayCast;

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize();
	
	if(monsterType == "Knight"):
		player = get_node("../Player");
		viewRayCast = get_node("RayCast2D");


# Called every physics tick
func _physics_process(delta):
	match monsterType:
		"Hogweed":
			hogweedAI(delta);
		"Gremlint":
			gremlintAI(delta);
		"Knight":
			knightAI(delta);
		"Chicken":
			chickenAI(delta);


# Handle hogweed behaviour
func hogweedAI(delta):
	# Wander for random durations
	wander(delta);
	
func chickenAI(delta):
	wander(delta);
	
# Handle gremlint behaviour
func gremlintAI(delta):
	if(wanderDuration <= 0):
		# Turn into a ball to roll left or right
		wanderDuration = rng.randi_range(10,50);
		match(rng.randi_range(1,3)):
			1:
				direction = Vector2(1,0);
				updateFacing("right");
			2:
				direction = Vector2(-1,0);
				updateFacing("left");
			3:
				direction = Vector2.ZERO;
				updateFacing("idle");
				
		movement = speed * direction * delta;
	else:
		wanderDuration -=1;
		var collision = move_and_collide(movement);
		
		# Check if we are walking into a wall
		if(collision != null):
			wanderDuration = 0;
			# Special case to unstick gremlints
			move_and_collide(-movement.normalized())


func knightAI(delta):
	# Check if we can see the player
	var towardsPlayer: Vector2 = (player.get_transform().origin - get_transform().origin).normalized()
	viewRayCast.set_cast_to(towardsPlayer * monsterViewRange);
	viewRayCast.force_raycast_update();
	
	var whatWeHit = viewRayCast.get_collider()
	
	if(whatWeHit != null && "Player" in whatWeHit.name ):
		var fastSpeed = speed * 2;
		movement = fastSpeed * towardsPlayer * delta;
		var collision = move_and_collide(movement);
		
		# Check if we are walking into a wall
		if(collision != null):
			wanderDuration = 0;
			# Special case to unstick gremlints
			move_and_collide(-movement.normalized())
	else:
		wander(delta);
	

# Common behavour. Wander randomly
func wander(delta):
	# Pick a random duration time if we aren't already wandering
	if (wanderDuration <= 0):
		wanderDuration = rng.randi_range(5, 50);
		# Pick a new direction to go
		match(rng.randi_range(1,4)):
			1:
				direction = Vector2(1, 0);
				updateFacing("right");
			2:
				direction = Vector2(-1, 0);
				updateFacing("left");
			3:
				direction = Vector2(0, 1);
				updateFacing("down");
			4:
				direction = Vector2(0, -1);
				updateFacing("up");
		
		movement = speed * direction * delta;
	else:
		# Move in our direction
		wanderDuration -= 1;
		var collision = move_and_collide(movement);
		
		# Check if we are walking into a wall
		if(collision != null):
			wanderDuration = 0;
			# Special case to unstick gremlints
			move_and_collide(-movement.normalized())


# Adjust sprite for up/down left/right facing
func updateFacing(newDirection):	
	var anim = get_node("AnimatedSprite");
	if(newDirection == "left"):
		anim.flip_h = true;
	else:
		anim.flip_h = false;
		
	anim.animation = newDirection;
