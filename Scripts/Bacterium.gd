extends CharacterBody2D
class_name Bacterium

@export var speed := 60.0

@onready var collision := $CollisionShape2D

var goal_pos : Vector2

func _ready():
	goal_pos = global_position
	
func _physics_process(delta):
	goal_pos = get_global_mouse_position()
	
	if goal_pos.distance_to(global_position) <= 5:
		return
	
	var direction = (goal_pos - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()
