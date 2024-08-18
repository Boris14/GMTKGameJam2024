extends CanvasLayer
class_name PopUp

@onready var continue_button := %ContinueButton
@onready var animation := $AnimationPlayer

func _ready():
	$PopUpBackground.modulate = Color.TRANSPARENT
	continue_button.pressed.connect(_on_continue_pressed)
	
func _on_continue_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func pop_up():
	visible = true
	animation.play("PopUp")

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
