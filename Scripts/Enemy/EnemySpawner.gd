extends Node2D
class_name EnemySpawner

# HARD:
#	"Basic": {"base": 10, "max":3},
#	"Shooter": {"base": 8, "max":3},
#	"Tank": {"base": 3, "max":3},
#	"Splitter": {"base": 1, "max":4},
#	"Freezer": {"base": 0, "max":5},
#	"AOE": {"base": 0, "max":5},

# EASY:
#	"Basic": {"base": 5, "max":3},
#	"Shooter": {"base": 2, "max":3},
#	"Tank": {"base": 1, "max":3},
#	"Splitter": {"base": 0, "max":3},
#	"Freezer": {"base": 0, "max":1},
#	"AOE": {"base": 0, "max":0},

@export var blood_cell_spawn_rate := 1.
@export var base_enemy_spawn_rate := 3.
@export var max_enemy_spawn_rate := 1.
@export var max_enemy_health_boost := 2.
@export var enemy_probabilities : Dictionary = {
	"Basic": {"base": 10, "max":3},
	"Shooter": {"base": 8, "max":3},
	"Tank": {"base": 3, "max":3},
	"Splitter": {"base": 1, "max":4},
	"Freezer": {"base": 0, "max":5},
	"AOE": {"base": 0, "max":5},
}

# Preload enemy scenes
var BasicEnemyScene = preload("res://Scenes/Enemy/enemy.tscn")
var ShooterEnemyScene = preload("res://Scenes/Enemy/ShooterEnemy.tscn")
var AOEEnemyScene = preload("res://Scenes/Enemy/AOEEnemy.tscn")
var TankEnemyScene = preload("res://Scenes/Enemy/TankEnemy.tscn")
var FreezerEnemyScene = preload("res://Scenes/Enemy/FreezerEnemy.tscn")
var SplitterEnemyScene = preload("res://Scenes/Enemy/SplitterEnemy.tscn")
var BloodCellEnemyScene = preload("res://Scenes/Enemy/BloodCellEnemy.tscn")

@onready var blood_cell_timer : Timer = Timer.new()

var total_spawn_chance: int = 0
var spawn_timer: float = 0.0
var time_to_next_spawn: float = -1.0

func calculate_probability(entry, difficulty) -> int:
	return int(lerp(entry["base"], entry["max"], difficulty))

# Update spawn chances
func spawn_chances():
	# Reaches 1 at 60% progress
	#var difficulty_factor = min(Globals.progress / 0.6, 1.0) 
	var difficulty_factor = Globals.immunity_response / 100.

	return {
		"Basic": calculate_probability(enemy_probabilities["Basic"], difficulty_factor),
		"Shooter": calculate_probability(enemy_probabilities["Shooter"], difficulty_factor),
		"Splitter": calculate_probability(enemy_probabilities["Splitter"], difficulty_factor),
		"AOE": calculate_probability(enemy_probabilities["AOE"], difficulty_factor),
		"Tank": calculate_probability(enemy_probabilities["Tank"], difficulty_factor),
		"Freezer": calculate_probability(enemy_probabilities["Freezer"], difficulty_factor),
	}

func blood_cell_timer_handler():
	var enemy_instance = BloodCellEnemyScene.instantiate()
	add_child(enemy_instance)
	
	var spawn_position = get_spawn_position(enemy_instance)
	if spawn_position == null:
		enemy_instance.queue_free()
	else:
		enemy_instance.position = spawn_position
		enemy_instance.adjust_movement_dir()

func set_next_spawn_time():
	var difficulty_factor = min(Globals.progress / 0.6, 1.0) 
	time_to_next_spawn = lerp(base_enemy_spawn_rate, max_enemy_spawn_rate, difficulty_factor)

func _ready():
	add_child(blood_cell_timer)
	blood_cell_timer.timeout.connect(blood_cell_timer_handler)
	
	randomize()
	# Calculate total spawn chance
	for chance in spawn_chances().values():
		total_spawn_chance += chance


func _process(delta):
	spawn_timer += delta
	if time_to_next_spawn > 0 and spawn_timer >= time_to_next_spawn:
		spawn_enemy()
		spawn_timer = 0.0
		set_next_spawn_time()


func start():
	for child in get_children():
		if child is Enemy:
			child.queue_free()
	set_next_spawn_time()
	blood_cell_timer.start(blood_cell_spawn_rate)

	
func stop():
	time_to_next_spawn = -1
	spawn_timer = 0

func spawn_enemy():
	var enemy_type = choose_enemy_type()
	var enemy_instance
	
	match enemy_type:
		"Splitter":
			enemy_instance = SplitterEnemyScene.instantiate()
		"Basic":
			enemy_instance = BasicEnemyScene.instantiate()
		"Shooter":
			enemy_instance = ShooterEnemyScene.instantiate()
		"AOE":
			enemy_instance = AOEEnemyScene.instantiate()
		"Tank":
			enemy_instance = TankEnemyScene.instantiate()
		"Freezer":
			enemy_instance = FreezerEnemyScene.instantiate()

	add_child(enemy_instance)
	
	var spawn_position = get_spawn_position(enemy_instance)
	if spawn_position == null:
		enemy_instance.queue_free()
	else:	
		var health_mult = lerp(1., max_enemy_health_boost, Globals.progress)
		enemy_instance.set_max_health(enemy_instance.max_health * health_mult)
		enemy_instance.position = spawn_position

func get_spawn_position(enemy : Enemy):
	var max_tries := 50
	var is_found := false
	var result := Vector2.ZERO
	var spawn_progress_pos = get_tree().get_first_node_in_group("spawn_progress").position
	while not is_found and max_tries > 0:	
		var spawn_distance = randf_range(50, 300)
		var spawn_angle = randf() * 2 * PI
		result = spawn_progress_pos + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_distance
		max_tries -= 1
		if can_spawn(enemy.radius, result):
			return result
	return null

func can_spawn(body_radius : float, position : Vector2) -> bool:
	var params := PhysicsShapeQueryParameters2D.new()
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = body_radius
	params.shape = circle_shape
	params.transform = Transform2D(0, position)
	var hits : Array = get_world_2d().direct_space_state.intersect_shape(params)
	
	return hits.size() == 0

func choose_enemy_type():
	var roll = randi() % total_spawn_chance
	var cumulative_chance = 0

	for enemy_type in spawn_chances():
		cumulative_chance += spawn_chances()[enemy_type]
		if roll < cumulative_chance:
			return enemy_type

	return "Basic"  # Fallback to basic enemy if something goes wrong
