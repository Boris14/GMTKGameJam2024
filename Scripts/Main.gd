extends Node2D

@export var camera_speed := 70.0
@export var start_delay := 0.0
@export var game_flow_speed := Vector2(0.008, 0.017)
@export var game_speed_at_max := 2.
@export var camera_initial_direction := Vector2(1, 0)
@export var camera_marker_detection_radius := 10
@export var bacteria_scene : PackedScene
@export var music_start_sound : AudioStream
@export var music_loop_sound : AudioStream
@export var win_sound : AudioStream
@export var loose_sound : AudioStream

@onready var enemy_spawner := $EnemySpawner
@onready var music_player := $MusicPlayer
@onready var heartbeat_player := $HeartbeatSoundPlayer
@onready var game_flow := %GameFlow
@onready var HUD := $Hud

var loose_screen : PopUp
var win_screen : PopUp
var sfx_player : AudioStreamPlayer
var bacteria : Bacteria
var has_won := false
var is_idle := true

func _ready():
	var loose_screen_scene = preload("res://Scenes/UI/LooseScreen.tscn")
	loose_screen = loose_screen_scene.instantiate()
	add_child(loose_screen)
	loose_screen.visible = false
	
	var win_screen_scene = preload("res://Scenes/UI/WinScreen.tscn")
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
	bacteria.start_bacteria($PlayerStartPosition.position)
	
	music_player.finished.connect(_on_music_start_sound_finished)
	game_flow.speed_scale = 0.0
	
func _input(event):
	if not is_idle:
		return
	if event is InputEventMouseButton:
		if event.is_pressed() and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
			start_game()
	
func _physics_process(delta):
	if game_flow.speed_scale > 0:
		music_player.volume_db = lerp(0., -10., Globals.immunity_response / 100.)
		heartbeat_player.volume_db = lerp(-15., 3.5, Globals.immunity_response / 100.)
		game_flow.speed_scale = lerp(game_flow_speed.x, game_flow_speed.y, Globals.progress)
		Engine.time_scale = lerp(1., game_speed_at_max, Globals.progress)

func start_game():
	is_idle = false
	Engine.time_scale = 1.0
	Globals.immunity_response = 0.0
	has_won = false
	enemy_spawner.stop()
	
	await get_tree().create_timer(start_delay).timeout
	game_flow.speed_scale = game_flow_speed.x
	music_player.stream = music_start_sound
	music_player.play()
	heartbeat_player.play()
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
	game_flow.speed_scale = 0.
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
