extends CanvasLayer

@export var click_sounds : Array[AudioStream]
@export var easy_scene : PackedScene
@export var hard_scene : PackedScene

var action : Callable

func _ready():
	%EasyLevelButton.pressed.connect(_on_easy_pressed)
	%HardLevelButton.pressed.connect(_on_hard_pressed)
	%QuitButton.pressed.connect(_on_quit_pressed)
	$AudioStreamPlayer.finished.connect(on_clicked_finished)
	%HardLevelButton.disabled = not Globals.is_level_2_unlocked
	
func _on_easy_pressed():
	action = func(): get_tree().change_scene_to_packed(easy_scene)
	play_click_sound()
	
func _on_hard_pressed():
	action = func(): get_tree().change_scene_to_packed(hard_scene)
	play_click_sound()
	
func _on_quit_pressed():
	action = func(): get_tree().quit()
	play_click_sound()

func on_clicked_finished():
	action.call()

func play_click_sound():
	$AudioStreamPlayer.stream = click_sounds.pick_random()
	$AudioStreamPlayer.play()
