extends Node3D

var enemy_count = 0
var planet_scenes = {
	"enemy": "res://Enemy/enemy_3d.tscn"
}

func spawn_enemy(enemy_type: String) -> bool:
	print("Attempting to spawn enemy")
	var limit = 10
	var bordermin = -200 + limit # Changed to negative to create a proper range
	var bordermax = 200 + limit
	var minPlanetDistance = 10
	
	var scene_path = planet_scenes.get(enemy_type)
	if not scene_path:
		print("Unknown enemy type: ", enemy_type)
		return false
	
	var spawned = load(scene_path)
	if not spawned:
		print("Failed to load enemy scene from: ", scene_path)
		return false
		
	var enemy_instance = spawned.instantiate()
	if not enemy_instance:
		print("Failed to instantiate enemy scene")
		return false
	
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
		
		# Check distance from planets
		for node in get_tree().get_nodes_in_group("planets"):
			var distance = random_pos.distance_to(node.position)
			if distance < minPlanetDistance:
				valid_position = false
				break
		
		# Check distance from other enemies
		for node in get_tree().get_nodes_in_group("enemies"):
			var distance = random_pos.distance_to(node.position)
			if distance < minPlanetDistance:
				valid_position = false
				break
		
		if valid_position:
			enemy_instance.position = random_pos
			print("Found valid position for enemy: ", random_pos)
		
		attempts += 1
	
	if valid_position:
		enemy_count += 1 
		var node_name = "Enemy_" + str(enemy_count)
		enemy_instance.name = node_name
		
		# Add enemy to the enemies group
		enemy_instance.add_to_group("enemies")
		
		add_child(enemy_instance)
		print("Successfully spawned enemy: ", node_name)
		return true
	else:
		print("Could not find valid position for enemy after ", max_attempts, " attempts")
		return false
		
func _ready() -> void:
	print("Starting enemy spawning")
	# Wait a frame to ensure all planets are loaded
	await get_tree().create_timer(0.1).timeout
	
	for i in range(80):
		var success = spawn_enemy("enemy")
		if not success:
			print("Failed to spawn enemy #", i + 1)
