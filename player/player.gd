extends RigidBody


var gravity_direction = Vector3()
var move_force = 30
var jump_force = 20
#planets will set this value for you (check the planet script)
var planet_name = "space"



func _ready():
	_calc_gravity_direction("planet_earth")


func _process(delta):
	if planet_name != "space":
		_calc_gravity_direction(planet_name)
	
	_move()
	
	
func _integrate_forces(state):
	_walk_around_planet(state)
	

func _calc_gravity_direction(planet):
	gravity_direction = (get_parent().get_node(planet).global_transform.origin - global_transform.origin).normalized()


func _walk_around_planet(state):
	# allign the players y-axis (up and down) with the planet's gravity direciton:
	state.transform.basis.y = -gravity_direction
	

func _move():
	#handles all input and logic related to character movement
	#move
	if Input.is_action_pressed("movement_forward"):
		add_central_force(move_force* global_transform.basis.z)
		
	if Input.is_action_pressed("movement_backward"):
		add_central_force(move_force* -global_transform.basis.z)

	if Input.is_action_pressed("movement_left"):
		add_central_force(move_force* global_transform.basis.x)

	if Input.is_action_pressed("movement_right"):
		add_central_force(move_force* -global_transform.basis.x)
	
	#jump:
	if Input.is_action_just_pressed("movement_jump"):
		apply_impulse(Vector3.UP, jump_force* global_transform.basis.y)

func set_planet_name(n):
	print ("setting new planet: ", n)
	planet_name = n
