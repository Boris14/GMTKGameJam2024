extends CanvasLayer

@export var click_sounds : Array[AudioStream]
@export var play_scene : PackedScene

var action : Callable

func _ready():
	%PlayButton.pressed.connect(_on_play_pressed)
	%QuitButton.pressed.connect(_on_quit_pressed)
	$AudioStreamPlayer.finished.connect(on_clicked_finished)
	
func _on_play_pressed():
	action = func(): get_tree().change_scene_to_packed(play_scene)
	play_click_sound()
	
func _on_quit_pressed():
	action = func(): get_tree().quit()
	play_click_sound()

func on_clicked_finished():
	action.call()

func play_click_sound():
	$AudioStreamPlayer.stream = click_sounds.pick_random()
	$AudioStreamPlayer.play()
