extends CanvasLayer

@export var progress_per_sec := 10.0

@onready var progress_bar := $TextureProgressBar
@onready var label = $Label

var min_immune_response := 0.0
var max_immune_response := 100.0
var visual_progress = 0.

func _ready():
	# Set up the progress bar
	progress_bar.min_value = min_immune_response
	progress_bar.max_value = max_immune_response
	progress_bar.value = Globals.immunity_response
	
	# Set up the label
	label.text = "Immunity Response"

func _process(delta):
	
	# Update the progress bar value
	visual_progress = lerpf(visual_progress, \
		Globals.immunity_response, 2. * delta)
	
	if not is_equal_approx(progress_bar.value, Globals.immunity_response):
		progress_bar.value = visual_progress
	else:
		progress_bar.value = Globals.immunity_response
	
