extends CharacterBody3D

@onready var idleTimer: Timer = $IdleTimer
@onready var alertTimer: Timer = $AlertTimer
@onready var rng = RandomNumberGenerator.new()
@onready var player = GameData.player # global player reference
@onready var pulling: bool = false
var nearest_planet = null
var gravity_direction = Vector3.ZERO

enum State {
	IDLE,
	ALERT,
	TRACKING,
}

const SPEED = 2.0
const JUMP_VELOCITY = 4.5
@onready var current_state = State.IDLE

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Ensure timers exist
	if not idleTimer or not alertTimer:
		print("Warning: Timers not found in ", name)
		return
		
	# Start in idle state
	current_state = State.IDLE
	idleTimer.start(rng.randf_range(2, 4))
	
	# Initial velocity
	velocity = Vector3(
		rng.randf_range(-2, 2),
		rng.randf_range(-0.5, 0.5),
		rng.randf_range(-2, 2)
	)
	

func _physics_process(delta):
	# Update gravity direction based on nearest planet
	update_nearest_planet()
	
	# Apply movement
	move_and_slide()

func _process(delta):
	match current_state:
		State.IDLE:
			# Velocity is handled by idle timer
			pass
		State.ALERT:
			velocity = Vector3.ZERO
		State.TRACKING:
			if player:
				velocity = position.direction_to(player.position) * SPEED

func update_nearest_planet():
	var shortest_distance = INF
	var planets = get_tree().get_nodes_in_group("planets")
	
	for planet in planets:
		var distance = global_position.distance_to(planet.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_planet = planet
			
	if nearest_planet:
		gravity_direction = (nearest_planet.global_position - global_position).normalized()

func _on_alert_body_entered(body):
	if body == player:
		current_state = State.ALERT
		idleTimer.stop()
		velocity = Vector3.ZERO
		alertTimer.start()
		get_node("BlackBox").visible = false

func _on_alert_body_exited(body):
	if body == player:
		alertTimer.stop()
		current_state = State.IDLE
		idleTimer.start(rng.randf_range(2, 4))

func _on_idle_timer_timeout():
	velocity = Vector3(
		rng.randf_range(-2, 2),
		rng.randf_range(-0.5, 0.5),
		rng.randf_range(-2, 2)
	)
	idleTimer.start(rng.randf_range(2, 4))

func _on_alert_timer_timeout():
	current_state = State.TRACKING
