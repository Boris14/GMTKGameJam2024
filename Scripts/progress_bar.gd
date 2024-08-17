extends Control

@onready var progress_bar = $ProgressBar
#@onready var label = $Label

func _ready():
	# Set up the progress bar
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = Globals.immunity_response
	
	# Set up the label
	#label.text = "Immunity Response"

func _process(delta):
	# Update the progress bar value
	progress_bar.value = Globals.immunity_response
