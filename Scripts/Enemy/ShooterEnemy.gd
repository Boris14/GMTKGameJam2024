extends Enemy
class_name ShooterEnemy

enum State { MOVE, SHOOT }

var current_state = State.MOVE
var state_timer: float = 0.0
var shots_fired: int = 0
var EnemyScene = preload("res://Scenes/Enemy/enemy.tscn")

func _ready():
	super._ready()
	health = 3
	max_health = health
	movement_speed = 120.0
	radius = 30.0
	$Icon.modulate = Color.DEEP_PINK
func step(delta):
	state_timer += delta
	var distance_to_closest_bacterium = position.distance_to(get_closest_bacterium_position())
	match current_state:
		State.MOVE:
			velocity = ((1 if distance_to_closest_bacterium < 200 else -1)*get_closest_bacterium_position().direction_to(position)).normalized().rotated((-1 if len(get_tree().get_nodes_in_group("bacterium")) % 5 == 0 else 1)*PI/3) * movement_speed
			if state_timer >= 5.0:
				current_state = State.SHOOT
				state_timer = 0.0
				velocity = Vector2.ZERO
				shots_fired = 0
		State.SHOOT:
			if state_timer >= 0.5:
				shoot()
				state_timer = 0.0
				shots_fired += 1
				if shots_fired >= 1:
					current_state = State.MOVE

func shoot():
	print("Shoot Tank cell")  # Replace with actual shooting logic


	# Instance the scene
	var enemy_instance = EnemyScene.instantiate()

	# Load and set the script
	var TankEnemyScript = load("res://Scripts/Enemy/TankEnemy.gd")
	enemy_instance.set_script(TankEnemyScript)
	# Add the instance to the scene tree
	get_parent().add_child(enemy_instance)
	enemy_instance._ready()
	enemy_instance.radius = randf_range(20,50)
	enemy_instance.movement_speed = randf_range(100,300)
	# Optionally, set the position of the new enemy
	enemy_instance.position = position + position.direction_to(get_closest_bacterium_position()) * (radius + enemy_instance.radius) # Or wherever you want it
	enemy_instance.direction = enemy_instance.position.direction_to(get_closest_bacterium_position())
