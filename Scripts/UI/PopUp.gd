extends CanvasLayer
class_name PopUp

enum ButtonAction
{
	MENU,
	LEVEL1,
	LEVEL2,
	QUIT
}

@export var click_sounds : Array[AudioStream]

@export var right_button_action : ButtonAction
@export var left_button_action : ButtonAction

@onready var right_button := %RightButton
@onready var left_button := %LeftButton
@onready var animation := $AnimationPlayer

var action_to_play : Callable

func _ready():
	$PopUpBackground.modulate = Color.TRANSPARENT
	right_button.pressed.connect(_on_right_button_pressed)
	left_button.pressed.connect(_on_left_button_pressed)
	$AudioStreamPlayer.finished.connect(on_clicked_finished)
	
func execute_action(action : ButtonAction):
	match(action):
		ButtonAction.MENU:
			action_to_play = func(): get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
		ButtonAction.LEVEL1:
			action_to_play = func():get_tree().change_scene_to_file("res://Scenes/Main.tscn")
		ButtonAction.LEVEL2:
			action_to_play = func():get_tree().change_scene_to_file("res://Scenes/Level2.tscn")
		ButtonAction.QUIT:
			action_to_play = func():get_tree().quit()
	play_click_sound()	
		
func on_clicked_finished():
	action_to_play.call()
	
func _on_right_button_pressed():
	execute_action(right_button_action)

func _on_left_button_pressed():
	execute_action(left_button_action)

func play_click_sound():
	$AudioStreamPlayer.stream = click_sounds.pick_random()
	$AudioStreamPlayer.play()

func pop_up():
	visible = true
	animation.play("PopUp")
