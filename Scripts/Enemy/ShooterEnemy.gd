extends Enemy
class_name ShooterEnemy

enum State { MOVE, SHOOT }

var current_state = State.MOVE
var state_timer: float = 0.0
var shots_fired: int = 0

func _ready():
	super._ready()
	health = 3
	max_health = health
	movement_speed = 150.0
	radius = 12.0

func step(delta):
	state_timer += delta
	
	match current_state:
		State.MOVE:
			velocity = (get_player_position() - global_position).normalized() * movement_speed
			if state_timer >= 1.0:
				current_state = State.SHOOT
				state_timer = 0.0
				velocity = Vector2.ZERO
				shots_fired = 0
		State.SHOOT:
			if state_timer >= 1.0:
				shoot()
				state_timer = 0.0
				shots_fired += 1
				if shots_fired >= 3:
					current_state = State.MOVE

func shoot():
	print("Shoot Tank cell")  # Replace with actual shooting logic
	# You can instantiate a Tank enemy here or use another method to "shoot" them
