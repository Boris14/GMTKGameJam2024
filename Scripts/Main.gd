extends Node2D

@export var camera_speed := 70.0
@export var camera_marker_detection_radius := 10

@onready var camera = $Camera2D

var camera_direction := Vector2(1, 0)
var camera_markers : Array[CameraMarker]

func _ready():
	for marker in %CameraMarkers.get_children():
		camera_markers.append(marker)
		
	
func _physics_process(delta):
	camera.position += delta * camera_speed * camera_direction
	
	var index_to_remove := -1
	for i in range(camera_markers.size()):
		var marker = camera_markers[i]
		if (marker.position - camera.position).length() <= camera_marker_detection_radius:
			camera_direction = marker.get_camera_direction()
			camera.position = marker.position
			index_to_remove = i
			
	if index_to_remove >= 0:
		var marker_to_remove = camera_markers[index_to_remove]
		camera_markers.remove_at(index_to_remove)
		marker_to_remove.queue_free()
		remove_child(marker_to_remove)
		
