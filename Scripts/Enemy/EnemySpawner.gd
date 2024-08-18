extends Node2D
class_name EnemySpawner

# Preload enemy scenes
var BasicEnemyScene = preload("res://Scenes/Enemy/enemy.tscn")
var ShooterEnemyScript = preload("res://Scripts/Enemy/ShooterEnemy.gd")
var AOEEnemyScript = preload("res://Scripts/Enemy/AOEEnemy.gd")
var TankEnemyScript = preload("res://Scripts/Enemy/TankEnemy.gd")
var AbsorberEnemyScript = preload("res://Scripts/Enemy/AbsorberEnemy.gd")
var FreezerEnemyScript = preload("res://Scripts/Enemy/FreezerEnemy.gd")
var ImmunityBoosterEnemyScript = preload("res://Scripts/Enemy/ImmunityBoosterEnemy.gd")

# Update spawn chances
var spawn_chances = {
	"Basic": 10,
	"Shooter": 10,
	"AOE": 10,
	"Tank": 10,
	"Absorber": 10,
	"Freezer": 1,
	"ImmunityBooster": 100  # Adjust this value as needed
}
var total_spawn_chance: int = 0
var spawn_timer: float = 0.0
var time_to_next_spawn: float = -1.0

func _ready():
	randomize()
	# Calculate total spawn chance
	for chance in spawn_chances.values():
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

	
func stop():
	time_to_next_spawn = -1
	spawn_timer = 0

func set_next_spawn_time():
	var immunity = Globals.immunity_response
	var min_time = lerp(0.3, 0.05, immunity / 100.0)
	var max_time = lerp(0.6, 0.1, immunity / 100.0)
	time_to_next_spawn = randf_range(min_time, max_time)


func spawn_enemy():
	var spawn_position = get_spawn_position()
	if spawn_position == null:
		return  # No valid spawn position found

	var enemy_type = choose_enemy_type()
	var enemy_instance = BasicEnemyScene.instantiate()

	match enemy_type:
		"ImmunityBooster":
			enemy_instance.set_script(ImmunityBoosterEnemyScript)
		"Basic":
			pass  # BasicEnemy is already the default
		"Shooter":
			enemy_instance.set_script(ShooterEnemyScript)
		"AOE":
			enemy_instance.set_script(AOEEnemyScript)
		"Tank":
			enemy_instance.set_script(TankEnemyScript)
		"Absorber":
			enemy_instance.set_script(AbsorberEnemyScript)
		"Freezer":
			enemy_instance.set_script(FreezerEnemyScript)

	enemy_instance.position = spawn_position
	add_child(enemy_instance)
	enemy_instance._ready()  # Call _ready manually to ensure proper initialization

func get_spawn_position():
	
	var spawn_distance = randf_range(50, 300)
	var spawn_angle = randf() * 2 * PI
	
	return get_tree().get_first_node_in_group("spawn_progress").position + Vector2(cos(spawn_angle), sin(spawn_angle)) * spawn_distance

func choose_enemy_type():
	var roll = randi() % total_spawn_chance
	var cumulative_chance = 0

	for enemy_type in spawn_chances:
		cumulative_chance += spawn_chances[enemy_type]
		if roll < cumulative_chance:
			return enemy_type

	return "Basic"  # Fallback to basic enemy if something goes wrong
