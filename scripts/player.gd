extends RigidBody3D
var direction = Vector3.BACK
var velocity = Vector3.ZERO
var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO

var gravity_direction = Vector3()
var move_force = 25
var jump_force = 15
var y_velo = 0

#planets will set this value for you (check the planet script)
var planet_name = "space"
#var h_rot = $Camroot/h.global_transform.basis.get_euler().y


func _ready():
	
	calc_gravity_direction(planet_name)
	lock_rotation = true  # Prevents the body from rotating
	continuous_cd = true  # Enables continuous collision detection



func _process(delta):
	if planet_name != "space":
		calc_gravity_direction(planet_name)
	_move()
	
func _integrate_forces(state):
	_walk_around_planet(state)
	
func calc_gravity_direction(planet):
	gravity_direction = (get_parent().get_node(NodePath(planet)).global_position - global_position).normalized()
	print(gravity_direction)

func _walk_around_planet(state):
	# allign the players y-axis (up and down) with the planet's gravity direciton:
	# First set the y-axis
	state.transform.basis.y = -gravity_direction
	
	# Then properly orthonormalize the other axes
	var new_basis = Basis()
	new_basis.y = -gravity_direction
	
	# Get the current forward direction (z-axis)
	var forward = -state.transform.basis.z
	
	# Calculate the right vector (x-axis)
	new_basis.x = forward.cross(-gravity_direction).normalized()
	
	# Recalculate forward vector to ensure orthogonality
	new_basis.z = new_basis.x.cross(new_basis.y).normalized()
	
	# Apply the new orthonormalized basis
	state.transform.basis = new_basis
	

func _move():
	#handles all input and logic related to character movement
	#move
	#direction = direction.rotated(Vector3.UP, h_rot).normalized()
	if Input.is_action_pressed("move_forward"):
		apply_central_force(move_force* global_transform.basis.z)
		
	if Input.is_action_pressed("move_back"):
		apply_central_force(move_force* -global_transform.basis.z)

	if Input.is_action_pressed("move_left"):
		apply_central_force(move_force* global_transform.basis.x*-1)

	if Input.is_action_pressed("move_right"):
		apply_central_force(move_force* -global_transform.basis.x*-1)
	
	#jump:
	if Input.is_action_just_pressed("jump"):

		apply_impulse(jump_force* global_transform.basis.y)


func set_planet_name(n):
	print ("setting new planet: ", n)
	planet_name = n
