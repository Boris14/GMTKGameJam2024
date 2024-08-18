extends Node2D

@export var camera_speed := 70.0
@export var start_delay := 2.0
@export var camera_initial_direction := Vector2(1, 0)
@export var camera_marker_detection_radius := 10
@export var bacteria_scene : PackedScene
@export var music_start_sound : AudioStream
@export var music_loop_sound : AudioStream

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
	
	music_player.finished.connect(_on_music_start_sound_finished)

	start_game()
	
func start_game():
	Globals.immunity_response = 0.0
	has_won = false
	enemy_spawner.stop()
	bacteria.start_bacteria()
	
	await get_tree().create_timer(start_delay).timeout
	music_player.stream = music_start_sound
	music_player.play()
	enemy_spawner.start()
	
func _on_music_start_sound_finished():
	if music_player.stream == music_start_sound:
		music_player.stream = music_loop_sound
		music_player.play()
	
func win_game():
	if has_won:
		return
		
	has_won = true
	print("WON")
	# Win Pop-up


func _on_bacteria_died():
	get_tree().reload_current_scene()
