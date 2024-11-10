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
var win = false
var is_on_floor = false
var floor_check_distance = 50  # Adjust based on your character's size

#planets will set this value for you (check the planet script)
var planet_name = "space"
#var h_rot = $Camroot/h.global_transform.basis.get_euler().y


func _ready():
	GameData.player = self
	calc_gravity_direction("planet_earth")
	lock_rotation = true  # Prevents the body from rotating
	continuous_cd = true  # Enables continuous collision detection
	$Camera3D.current = false

func _process(delta):
	print(planet_name)
	if planet_name != "space":
		calc_gravity_direction(planet_name)
	else: 
		$AnimationPlayer.play("Swim")
		lock_rotation = false
	_move()
	
func _integrate_forces(state):
	_walk_around_planet(state)
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider:
			print("Touching: ", collider.name)
			planet_name = collider.name 
		print(linear_velocity.length())
		
		if (collider.name == planet_name) and (linear_velocity.length() < .2) and (not win): 
			# rotate to face screen
			$AnimationPlayer.play("Idle")
		

				
		
func calc_gravity_direction(planet):
	print(planet_name)
	# First try to get the exact node path
	var planet_node = get_parent().get_node_or_null(NodePath(planet))
	
	# If that fails, try to find the node by searching for partial name match
	if planet_node == null:
		for node in get_parent().get_children():
			if node.name.begins_with(planet):
				planet_node = node
				break
			
	
	# If we found a valid planet node, calculate gravity direction
	if planet_node != null:
		gravity_direction = (planet_node.global_position - global_position).normalized()
	else:
		print("Could not find planet: ", planet)
		# Fallback to default gravity or handle error as needed
		#gravity_direction = Vector3.DOWN
func _walk_around_planet(state):
	# allign the players y-axis (up and down) with the planet's gravity direciton:
	# First set the y-axis
	
	#while(state.transform.basis.y.dot(-gravity_direction) <= 0.80):
	var ex_angle = acos(state.transform.basis.y.dot(-gravity_direction))
			#state.transform.basis.y.z = lerp_angle(state.transform.basis.y.z,ex_angle, 1*get_physics_process_delta_time())
			#state.transform.basis.y.normalized()

	state.transform.basis.y.z = lerp_angle(0,ex_angle, 5*get_physics_process_delta_time())

	#state.transform.basis.y = -gravity_direction
	
	# Then properly orthonormalize the other axes
	var new_basis = Basis()
	new_basis.y = -gravity_direction
	#Get the current forward direction (z-axis)
	var forward = -state.transform.basis.z
	
	# Calculate the right vector (x-axis)
	new_basis.x = forward.cross(-gravity_direction).normalized()
	
	# Recalculate forward vector to ensure orthogonality
	new_basis.z = new_basis.x.cross(new_basis.y).normalized()
	
	# Apply the new orthonormalized basis
	state.transform.basis = new_basis
	


var target_rotation = 0
func _move():
	
	if Input.is_action_just_pressed("goto_win"):
		position = get_parent().get_node("moon_2").position
		position.y += 10
		print("macernea")
		win = true

	#handles all input and logic related to character movement
	#move
	#direction = direction.rotated(Vector3.UP, h_rot).normalized()
	if planet_name != "space" and (not win):
		if Input.is_action_just_pressed("jump"):
			apply_impulse(jump_force* global_transform.basis.y)
			$AnimationPlayer.play("Run n Dive")
		var input_dir = Vector2.ZERO
	
	# Get input direction
		if Input.is_action_pressed("move_right"):
			input_dir.x += 1
			$AnimationPlayer.play("Run")
		if Input.is_action_pressed("move_left"):
			input_dir.x -= 1
			$AnimationPlayer.play("Run")
		if Input.is_action_pressed("move_forward"):
			input_dir.y += 1
			$AnimationPlayer.play("Run")
		if Input.is_action_pressed("move_back"):
			input_dir.y -= 1
			$AnimationPlayer.play("Run")
			
	# Normalize input direction
		input_dir = input_dir.normalized()
		if input_dir != Vector2.ZERO:
		# Calculate target rotation based on input direction
			target_rotation = atan2(input_dir.x, input_dir.y)
		
		# Calculate movement force direction
			
			var force_dir = +global_transform.basis.z * input_dir.y - global_transform.basis.x * input_dir.x
		
		# Apply movement force
			var temp = (linear_velocity + force_dir*get_process_delta_time())
			var mag = sqrt(temp.dot(temp))

			
			if (mag < 10):
				apply_central_force(move_force * force_dir)
			
			sprite.rotation.z = lerp_angle(sprite.rotation.z, target_rotation, 1* get_physics_process_delta_time())

	if (planet_name == "space")and (not win):
		var speed = 10
		var rotate_speed = 10
		var tilt_effect = 5.0
		var tilt = 10.0
		var turn = 10.0
		var turn_torque = 10.0
		var torque_strength = 10
		lock_rotation = true 
		var rotation_input = Vector3(0, 0, 0) # Disable automatic rotation by physics engine
		if Input.is_action_pressed("move_right"):
			#rotation = Quaternion(, rotate_speed*get_physics_process_delta_time())*rotation
			#global_transform.basis.z = global_transform.basis.z.rotated(global_transform.basis.y, rotate_speed * get_physics_process_delta_time())
			#rotation_input.y += torque_strength
			#global_transform.rotated_local()
			rotation.y += turn * get_physics_process_delta_time()
			#turn * get_physics_process_delta_time()
		if Input.is_action_pressed("move_left"):
			rotation.y -= turn * get_physics_process_delta_time()
			#rotation = Quaternion(global_transform.basis.x, -rotate_speed*get_physics_process_delta_time())*rotation
			#global_transform.basis.z = global_transform.basis.z.rotated(global_transform.basis.y, -rotate_speed * get_physics_process_delta_time())
			#rotation_input.y -= torque_strength
		if Input.is_action_pressed("move_forward"):

			rotation.x -= tilt * get_physics_process_delta_time() 

		if Input.is_action_pressed("move_back"):

			rotation.x += tilt * get_physics_process_delta_time()

		position += global_transform.basis.z * speed * get_physics_process_delta_time()
		$AnimationPlayer.play("Swim")
		print(rotation)
		
	if win == true:
		$AnimationPlayer.play("Macarena")
		sprite.rotation.z = lerp_angle(sprite.rotation.z, PI, get_physics_process_delta_time())
		#sprite.rotation.y = lerp_angle(sprite.rotation.y, -10*input_dir.x, 1* get_physics_process_delta_time())
		#sprite.rotation.x = lerp_angle(sprite.rotation.x, -10*input_dir.y, 1* get_physics_process_delta_time())
	# Smoothly interpolate sprite rotation

func set_planet_name(n):
	print ("setting new planet: ", n)
	planet_name = n
