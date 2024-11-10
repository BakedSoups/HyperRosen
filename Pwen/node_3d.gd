extends Node3D

@export var target_path: NodePath
@export var offset: Vector3 = Vector3(0, 10, 10)  # Camera offset from player
@export var look_offset: Vector3 = Vector3(0, 0, 0)  # Where camera looks ahead of player
@export var interpolation_speed: float = 5.0
@export var rotation_interpolation_speed: float = 3.0
@export var min_zoom: float = 5.0
@export var max_zoom: float = 15.0
@export var zoom_speed: float = 0.5

@onready var camera: Camera3D = $Camera3D
@onready var target: Node3D = get_node(target_path)

var current_offset: Vector3
var target_position: Vector3
var current_rotation: Vector3
var zoom_level: float = 1.0

func _ready():
	current_offset = offset
	# Start at target position to avoid initial jump
	if target:
		global_position = target.global_position + offset

func _physics_process(delta: float):
	if !target:
		return
		
	# Update zoom level with mouse wheel
	if Input.is_action_just_released("zoom_in"):
		zoom_level = clamp(zoom_level - zoom_speed, 0.5, 2.0)
	elif Input.is_action_just_released("zoom_out"):
		zoom_level = clamp(zoom_level + zoom_speed, 0.5, 2.0)
	
	# Calculate target position with zoom
	target_position = target.global_position + current_offset * zoom_level
	
	# Smoothly interpolate position
	global_position = global_position.lerp(target_position, interpolation_speed * delta)
	
	# Calculate look target (ahead of player)
	var look_target = target.global_position + look_offset
	
	# Make camera look at target smoothly
	var target_transform = camera.transform.looking_at(look_target, Vector3.UP)
	camera.transform = camera.transform.interpolate_with(target_transform, rotation_interpolation_speed * delta)
	
	# Optional: Add screen shake when needed
	if Input.is_action_just_pressed("screen_shake"):
		add_screen_shake(0.5, 0.2)

func add_screen_shake(intensity: float, duration: float):
	var shake_tween = create_tween()
	shake_tween.tween_method(
		shake_camera,
		intensity,
		0.0,
		duration
	)

func shake_camera(intensity: float):
	camera.h_offset = randf_range(-intensity, intensity)
	camera.v_offset = randf_range(-intensity, intensity)

# Call this to change camera behavior during different game states
func set_camera_state(new_offset: Vector3, new_look_offset: Vector3, transition_time: float = 1.0):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "current_offset", new_offset, transition_time)
	tween.tween_property(self, "look_offset", new_look_offset, transition_time)
