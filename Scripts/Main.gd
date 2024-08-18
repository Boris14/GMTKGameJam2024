extends Node2D

@export var camera_speed := 70.0
@export var start_delay := 2.0
@export var camera_initial_direction := Vector2(1, 0)
@export var camera_marker_detection_radius := 10
@export var bacteria_scene : PackedScene

@onready var camera := $Camera2D
@onready var enemy_spawner := $EnemySpawner
@onready var music_player := $MusicPlayer
@onready var enemy_spawm_polygon := $EnemySpawnPolygon

var camera_initial_position : Vector2
var camera_direction := camera_initial_direction
var camera_markers : Array[CameraMarker]
var bacteria : Bacteria
var has_won := false

func _ready():
	camera_initial_position = camera.position
	bacteria = bacteria_scene.instantiate()
	bacteria.died.connect(_on_bacteria_died)
	bacteria.win_method = win_game
	add_child(bacteria)
	bacteria.z_index = 1

	start_game()
	
func start_game():
	has_won = false
	enemy_spawner.stop()
	camera.position = camera_initial_position
	camera_direction = Vector2.ZERO
	aquire_camera_markers()
	bacteria.start_bacteria()
	
	await get_tree().create_timer(start_delay).timeout
	music_player.play()
	camera_direction = camera_initial_direction
	enemy_spawner.start()
	
func win_game():
	if has_won:
		return
		
	has_won = true
	print("WON")
	# Win Pop-up

func _physics_process(delta):
	camera.position += delta * camera_speed * camera_direction
	
	var index_to_remove := -1
	for i in range(camera_markers.size()):
		var marker = camera_markers[i]
		if (marker.position - camera.position).length() <= camera_marker_detection_radius:
			camera_direction = marker.get_camera_direction()
			camera.position = marker.position
			index_to_remove = i
			
	if index_to_remove >= 0:
		var marker_to_remove = camera_markers[index_to_remove]
		camera_markers.remove_at(index_to_remove)
		
func aquire_camera_markers():
	camera_markers.clear()
	for marker in %CameraMarkers.get_children():
		camera_markers.append(marker)
		
func _on_bacteria_died():
	music_player.stop()
	start_game()
