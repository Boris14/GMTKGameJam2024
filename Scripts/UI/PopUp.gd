extends CanvasLayer
class_name PopUp

@onready var continue_button := %ContinueButton

func _ready():
	continue_button.pressed.connect(_on_continue_pressed)
	
func _on_continue_pressed():
	print("PRESSED")
	queue_free()
