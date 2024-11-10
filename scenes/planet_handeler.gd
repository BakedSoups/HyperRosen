extends Node3D
var moon_count = 0

# Dictionary mapping planet names to their scene paths
var planet_scenes = {
	"moon": "res://planets/moon.tscn",
	"mars": "res://planets/mars.tscn",
	"planet_earth": "res://planets/planet_earth.tscn"
	# Add more planets as needed
}

func spawn_planet(planet_type: String) -> bool:
	print(planet_type)
	var bordermin = 200
	var bordermax = 200
	var maxGap = 300
	
	if planet_type == 'mars':
		bordermin = -500
		bordermax =  500
		maxGap = 300
	elif planet_type == 'moon':
		bordermin = -200
		bordermax =  200 
		maxGap = 80
	elif planet_type == 'planet_earth':
		bordermin = -500
		bordermax =  500
		maxGap = 300

		
	var scene_path = planet_scenes.get(planet_type)
	if not scene_path:
		print("Unknown planet type: ", planet_type)
		return false
		
	var spawned = load(scene_path)
	var spawned_scene_copy = spawned.instantiate()
	
	var valid_position = false
	var max_attempts = 100
	var attempts = 0
	
	while !valid_position and attempts < max_attempts:
		var random_pos = Vector3(
			randf_range(bordermin, bordermax),
			randf_range(bordermin, bordermax), 
			randf_range(bordermin, bordermax)
		)
		
		valid_position = true
		
		for node in get_children():
			if node.is_in_group("planets"):
				var distance = random_pos.distance_to(node.position)
				if distance < maxGap:
					valid_position = false
					break
		
		if valid_position:
			spawned_scene_copy.position = random_pos
		
		attempts += 1
	
	if valid_position:
		var node_name = ""
		if planet_type == "moon":
			moon_count += 1
			node_name = "moon_" + str(moon_count)
		else:
			node_name = planet_type
			
		# Set name for the root node
		spawned_scene_copy.name = node_name
		
		# Find and set name for the StaticBody3D
		var static_body = spawned_scene_copy.get_node("StaticBody3D")
		if static_body:
			static_body.name = node_name
			
		add_child(spawned_scene_copy)
		return true
	else:
		print("Could not find valid position for ", planet_type)
		return false
		
func _ready() -> void:
	# List of planets to spawn
	for i in range(12):
		var planets_to_spawn = ["mars","mars","planet_earth", "moon","moon"]
		var rng = RandomNumberGenerator.new()

		#var rand = planets[rng.randi_range(0,planets_to_spawn)]
		#load("res://planets/%s.tscn" % rand)
		
		# Spawn each planet in the list
		for planet_type in planets_to_spawn:
			spawn_planet(planet_type)
