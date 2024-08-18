extends Node2D

@export var camera_speed := 70.0
@export var start_delay := 2.0
@export var camera_initial_direction := Vector2(1, 0)
@export var camera_marker_detection_radius := 10
@export var bacteria_scene : PackedScene

@onready var camera := $Camera2D
@onready var enemy_spawner := $EnemySpawner
@onready var music_player := $MusicPlayer


var bacteria : Bacteria
var has_won := false

func _ready():
	bacteria = bacteria_scene.instantiate()
	bacteria.died.connect(_on_bacteria_died)
	bacteria.initial_bacteria_position = $PlayerStartPosition.position
	bacteria.win_method = win_game
	add_child(bacteria)
	bacteria.z_index = 1

	start_game()
	
func start_game():
	has_won = false
	enemy_spawner.stop()
	bacteria.start_bacteria()
	
	await get_tree().create_timer(start_delay).timeout
	music_player.play()
	enemy_spawner.start()
	
func win_game():
	if has_won:
		return
		
	has_won = true
	print("WON")
	# Win Pop-up



func _on_bacteria_died():
	music_player.stop()
	start_game()
