extends Node2D

@export var camera_speed := 70.0
@export var start_delay := 2.0
@export var camera_initial_direction := Vector2(1, 0)
@export var camera_marker_detection_radius := 10
@export var bacteria_scene : PackedScene
@export var win_screen_scene : PackedScene
@export var loose_screen_scene : PackedScene
@export var music_start_sound : AudioStream
@export var music_loop_sound : AudioStream
@export var win_sound : AudioStream
@export var loose_sound : AudioStream

@onready var enemy_spawner := $EnemySpawner
@onready var music_player := $MusicPlayer
@onready var game_flow := %GameFlow
@onready var HUD := %Hud

var loose_screen : PopUp
var win_screen : PopUp
var sfx_player : AudioStreamPlayer
var bacteria : Bacteria
var has_won := false

func _ready():
	loose_screen = loose_screen_scene.instantiate()
	add_child(loose_screen)
	loose_screen.visible = false
	
	win_screen = win_screen_scene.instantiate()
	add_child(win_screen)
	win_screen.visible = false
	
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	bacteria = bacteria_scene.instantiate()
	bacteria.died.connect(_on_bacteria_died)
	bacteria.initial_bacteria_position = $PlayerStartPosition.position
	bacteria.win_method = win_game
	add_child(bacteria)
	bacteria.z_index = 1
	
	music_player.finished.connect(_on_music_start_sound_finished)

	start_game()
	
func _physics_process(delta):
	game_flow.speed_scale = lerp(0.008, 0.015, Globals.progress)
	Engine.time_scale = lerp(1, 2, Globals.progress)

func start_game():
	Engine.time_scale = 1.0
	Globals.immunity_response = 0.0
	has_won = false
	enemy_spawner.stop()
	bacteria.start_bacteria()
	
	await get_tree().create_timer(start_delay).timeout
	game_flow.active = true
	music_player.stream = music_start_sound
	music_player.play()
	enemy_spawner.start()
	
func _on_music_start_sound_finished():
	if music_player.stream == music_start_sound:
		music_player.stream = music_loop_sound
		music_player.play()
	
func stop_game_flow():
	bacteria.queue_free()
	if HUD:
		HUD.queue_free()
	music_player.stop()
	game_flow.active = false
	enemy_spawner.stop()

func win_game():
	if has_won:
		return
		
	has_won = true
	stop_game_flow()
	
	await get_tree().create_timer(0.2).timeout
	
	if win_sound:
		sfx_player.stream = win_sound
		sfx_player.play()

	win_screen.pop_up()


func _on_bacteria_died():
	if has_won:
		return
	
	stop_game_flow()	
	
	await get_tree().create_timer(0.2).timeout
	
	loose_screen.pop_up()
	
	if loose_sound:
		sfx_player.stream = loose_sound
		sfx_player.play()
