extends CharacterBody3D

@onready var idleTimer: Timer = $IdleTimer
@onready var alertTimer: Timer = $AlertTimer
@onready var rng = RandomNumberGenerator.new()
@onready var player = GameData.player # global player reference
@onready var pulling: bool = false
@onready var planet_name = "planet_earth"
@onready var gravity_direction = (get_parent().get_node(NodePath(planet_name)).global_position - global_position).normalized() 

enum State {
	IDLE,
	ALERT,
	TRACKING,
}


const SPEED = 2.0
const JUMP_VELOCITY = 4.5
@onready var current_state = State.IDLE

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	pass

func _physics_process(delta):
	move_and_slide()
	#print("Current State:", current_state)
	print("Enemy Position: ", position)


func _process(delta):
	match (current_state):
		State.IDLE:
			# velocity = Random
			pass
		State.ALERT:
			#idleTimer.stop()
			velocity = Vector3.ZERO
		State.TRACKING:
			print("I'M TRACKING")
			velocity = position.direction_to(player.position) * SPEED
	print(velocity)
			# make this pull the player in like a planet by setting pulling = true


func _on_alert_body_entered(body):
	print("ENTERED MY BODY")
	if body == player:
		current_state = State.ALERT
		idleTimer.stop()
		velocity = Vector3.ZERO
		alertTimer.start()
	
	# maybe put a ! over its head


func _on_alert_body_exited(body):
	print("EXITED MY BODY")
	if body == player:
		alertTimer.stop()
		current_state = State.IDLE
		idleTimer.start(rng.randf_range(2,4))

# re-randomize enemy direction every couple of seconds
func _on_idle_timer_timeout():
	velocity = Vector3(rng.randf_range(-2,2),rng.randf_range(-0.5,0.5),rng.randf_range(-2,2))
	idleTimer.start(rng.randf_range(2,4))

func _on_alert_timer_timeout():
	current_state = State.TRACKING
