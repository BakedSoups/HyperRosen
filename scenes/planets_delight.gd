extends Node3D

@export var num_planets = 15
@export var spawn_radius = 100.0

func _ready():
	generate_planets()

func generate_planets():
	for i in num_planets:
		var planet = Planet.new()
		# Random position
		var pos = Vector3(
			randf_range(-spawn_radius, spawn_radius),
			randf_range(-spawn_radius, spawn_radius),
			randf_range(-spawn_radius, spawn_radius)
		)
		planet.position = pos
		planet.create()
		add_child(planet)
