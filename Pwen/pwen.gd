extends RigidBody3D
@onready var sprite = $Armature/Skeleton3D/Object_penguin_tex_jpg
var direction = Vector3.BACK
@onready var velocity = Vector3.ZERO
var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO

var gravity_direction = Vector3()
var move_force = 25
var jump_force = 15
var y_velo = 0

@onready var pause_menu = $"../CanvasLayer/pause_menu"

var is_on_floor = false
var floor_check_distance = 50  # Adjust based on your character's size

#planets will set this value for you (check the planet script)
var planet_name = "space"
#var h_rot = $Camroot/h.global_transform.basis.get_euler().y


func _ready():
	calc_gravity_direction("planet_earth")
	lock_rotation = true  # Prevents the body from rotating
	continuous_cd = true  # Enables continuous collision detection

func _process(delta):
	print(planet_name)
	if planet_name != "space":
		calc_gravity_direction(planet_name)
	else: 
		$AnimationPlayer.play("Swim")
	pause_menu.testEsc()
	_move()
	
func _integrate_forces(state):
	_walk_around_planet(state)
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider:
			print("Touching: ", collider.name)
			planet_name = collider.name 
		print(linear_velocity.length())
		if collider.name == planet_name and linear_velocity.length() < .2: 
			$AnimationPlayer.play("Idle")
			
		
func calc_gravity_direction(planet):
	# Try to find the moon by its name in the parent's children
	var planet_node = null
	
	# Print all children names for debugging
	print("Looking for planet: ", planet)
	for node in get_parent().get_children():
		print("Found node: ", node.name)
		if node.name == planet:
			planet_node = node
			break
			
	if planet_node != null:
		gravity_direction = (planet_node.global_position - global_position).normalized()
		print("Found planet, gravity direction: ", gravity_direction)
	else:
		# If we can't find it directly, try searching deeper
		for node in get_parent().get_children():
			# Try to find it in the node's children
			var found_node = node.find_child(planet, true, false)  # true for recursive, false for not owned
			if found_node:
				planet_node = found_node
				break
				
		if planet_node != null:
			gravity_direction = (planet_node.global_position - global_position).normalized()
			print("Found planet in children, gravity direction: ", gravity_direction)
		else:
			print("Could not find planet: ", planet)
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
	if planet_name != "space":
	
		if Input.is_action_pressed("move_forward"):
			$AnimationPlayer.play("Run")
			apply_central_force(move_force* global_transform.basis.z)
			sprite.rotation.z = PI * 0
			
		if Input.is_action_pressed("move_back"):
			apply_central_force(move_force* -global_transform.basis.z)
			$AnimationPlayer.play("Run")
			sprite.rotation.z = PI 
			

		if Input.is_action_pressed("move_left"):
			apply_central_force(move_force* global_transform.basis.x)
			$AnimationPlayer.play("Run")
			sprite.rotation.z = PI * -0.5 

		if Input.is_action_pressed("move_right"):
			apply_central_force(move_force* -global_transform.basis.x)
			$AnimationPlayer.play("Run")
			sprite.rotation.z = PI * 0.5 
		
		#jump:
		if Input.is_action_just_pressed("jump"):
			apply_impulse(jump_force* global_transform.basis.y)
			$AnimationPlayer.play("Run n Dive")
	
func set_planet_name(n):
	print ("setting new planet: ", n)
	planet_name = n
