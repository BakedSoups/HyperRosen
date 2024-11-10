extends Node3D
class_name Planet

# Properties with random defaults
var radius: float
var gravity_strength: float
var planet_colors = [
	Color(0.8, 0.4, 0.2),  # Rocky red
	Color(0.3, 0.5, 0.8),  # Ocean blue
	Color(0.9, 0.9, 0.9),  # Ice white
	Color(0.6, 0.4, 0.2),  # Desert brown
	Color(0.4, 0.8, 0.3)   # Forest green
]

func _init():
	# Random size
	radius = randf_range(5.0, 15.0)
	# Bigger planets have more gravity
	gravity_strength = radius * 2

func create():
	# Create the planet mesh
	var planet_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = radius
	planet_mesh.mesh = sphere
	
	# Random texture/color
	var material = StandardMaterial3D.new()
	material.albedo_color = planet_colors[randi() % planet_colors.size()]
	# Optional: Add some noise to the texture
	material.roughness = randf_range(0.3, 0.8)
	sphere.material = material
	
	# Add collision
	var body = StaticBody3D.new()
	var collision = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = radius
	collision.shape = sphere_shape
	body.add_child(collision)
	planet_mesh.add_child(body)
	
	# Add gravity field
	var gravity_field = Area3D.new()
	var gravity_shape = CollisionShape3D.new()
	var gravity_sphere = SphereShape3D.new()
	gravity_sphere.radius = radius * 3  # Gravity reaches 3x planet size
	gravity_shape.shape = gravity_sphere
	gravity_field.add_child(gravity_shape)
	
	# Add gravity behavior
	gravity_field.body_entered.connect(_on_body_entered)
	gravity_field.body_exited.connect(_on_body_exited)
	planet_mesh.add_child(gravity_field)
	
	add_child(planet_mesh)

var bodies_in_gravity = []  # Track what's in gravity field

func _on_body_entered(body: Node3D):
	if body.is_in_group("affected_by_gravity"):
		bodies_in_gravity.append(body)

func _on_body_exited(body: Node3D):
	bodies_in_gravity.erase(body)

func _physics_process(delta):
	for body in bodies_in_gravity:
		if body.has_method("add_central_force"):
			var direction = global_position - body.global_position
			var distance = direction.length()
			if distance > 0:
				var force = direction.normalized() * (gravity_strength / distance)
				body.add_central_force(force)
