extends Node3D
var render = 700
var moon_count = 0
# Dictionary mapping planet names to their scene paths
var planet_scenes = {
	"moon": "res://planets/moon.tscn",
	"mars": "res://planets/mars.tscn",
	"planet_earth": "res://planets/planet_earth.tscn",
	"star": "res://addons/naejimer_3d_planet_generator/scenes/star.tscn",
	"ice" : "res://planets/iceplanet.tscn",
	"lava": "res://planets/lava.tscn"
}

# Dictionary defining spawn parameters for each planet type
var planet_params = {
	"mars": {
		"bordermin": (-500 - render),  # -500 - limit
		"bordermax": (500 + render),   # 500 + limit
		"maxGap": 30
	},
	"moon": {
		"bordermin":(-200-render),  # -200 - limit
		"bordermax": (200+render),   # 200 + limit
		"maxGap": 80
	},
	"planet_earth": {
		"bordermin":(-500+-render),  # -500 - limit
		"bordermax": (500+render),   # 500 + limit
		"maxGap": 30
	},
	"star": {
		"bordermin":(-500+-render),  # -500 - limit
		"bordermax": (500+render),   # 500 + limit
		"maxGap": 90
	},
		"ice": {
		"bordermin":(-500+-render),  # -500 - limit
		"bordermax": (500+render),   # 500 + limit
		"maxGap": 90
	},
	"lava": {
		"bordermin":(-400+-render),  # -500 - limit
		"bordermax": (300+render),   # 500 + limit
		"maxGap": 40
	}
}

func spawn_planet(planet_type: String) -> bool:
	print(planet_type)
	
	var params = planet_params[planet_type]
	if not params:
		params = {
			"bordermin": 200,
			"bordermax": 200,
			"maxGap": 30
		}
		
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
			randf_range(params.bordermin, params.bordermax),
			randf_range(params.bordermin, params.bordermax), 
			randf_range(params.bordermin, params.bordermax)
		)
		
		valid_position = true
		
		for node in get_children():
			if node.is_in_group("planets"):
				var distance = random_pos.distance_to(node.position)
				if distance < params.maxGap:
					valid_position = false
					break
		
		if valid_position:
			spawned_scene_copy.position = random_pos
		
		attempts += 1
	
	if valid_position:
		var node_name = ""
		moon_count += 1 
		node_name = "moon_" + str(moon_count)
			
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

func spawn_planets_with_percentages(total_planets: int, percentages: Dictionary) -> void:
	# Calculate number of each type to spawn based on percentages
	var planet_counts = {}
	var remaining = total_planets
	
	# First pass: calculate whole numbers
	for planet_type in percentages:
		var count = floor(total_planets * (percentages[planet_type] / 100.0))
		planet_counts[planet_type] = count
		remaining -= count
	
	# Second pass: distribute remaining planets based on decimal parts
	while remaining > 0:
		var highest_remainder = 0.0
		var selected_type = ""
		
		for planet_type in percentages:
			var exact_count = total_planets * (percentages[planet_type] / 100.0)
			var remainder = exact_count - floor(exact_count)
			
			if remainder > highest_remainder:
				highest_remainder = remainder
				selected_type = planet_type
		
		if selected_type != "":
			planet_counts[selected_type] += 1
			percentages[selected_type] = 0  # Prevent this type from being selected again
			remaining -= 1
	
	# Spawn the calculated number of each planet type
	for planet_type in planet_counts:
		for i in range(planet_counts[planet_type]):
			spawn_planet(planet_type)

func _ready() -> void:
	# Define percentages for each planet type (must add up to 100)
	var planet_percentages = {
		"mars": 15,        # 30% Mars
		"moon": 30,        # 30% Moons
		"planet_earth": 20, # 20% Earth
		"star": 5,       # 20% Stars
		"ice":10,
		"lava": 20
	}
	
	# Spawn 50 total planets with the defined percentages
	spawn_planets_with_percentages(250, planet_percentages)
