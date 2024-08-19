extends CanvasLayer

@export var progress_per_sec := 10.0
@export var progress_warning_percent := 80.

@onready var progress_bar := $TextureProgressBar
@onready var label = $Label
@onready var animation := $AnimationPlayer

var min_immune_response := 0.0
var max_immune_response := 100.0
var visual_progress = 0.
var is_warning_on := false

func _ready():
	# Set up the progress bar
	progress_bar.min_value = min_immune_response
	progress_bar.max_value = max_immune_response
	progress_bar.value = Globals.immunity_response
	
	# Set up the label
	label.text = "Immunity Response"
	
	animation.play("Default")

func _process(delta):
	# Update the progress bar value
	visual_progress = lerpf(visual_progress, \
		Globals.immunity_response, 2. * delta)
	
	if not is_equal_approx(progress_bar.value, Globals.immunity_response):
		progress_bar.value = visual_progress
	else:
		progress_bar.value = Globals.immunity_response
	
	if not is_warning_on and progress_bar.value >= progress_warning_percent:
		animation.play("WarningOn")
		is_warning_on = true
		
	if is_warning_on and progress_bar.value < progress_warning_percent:
		animation.play("WarningOff")
		is_warning_on = false
