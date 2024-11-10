extends Node3D
var enemy_count = 0  # Changed from moon_count to be more descriptive
# Dictionary mapping enemy names to their scene paths
var enemy_scenes = {
	"enemy": "res://Enemy/enemy_3d.tscn"
}

func spawn_enemy(enemy_type: String) -> bool:
	print(enemy_type)
	var bordermin = -90  # Changed to negative to allow spawning on both sides
	var bordermax = 90
	var maxGap = 60
	
	var scene_path = enemy_scenes.get(enemy_type)
	if not scene_path:
		print("Unknown enemy type: ", enemy_type)
		return false
		
	var spawned = load(scene_path)
	var spawned_scene_copy = spawned.instantiate()
	
	var valid_position = false
	var max_attempts = 100
	var attempts = 0
	var random_pos = Vector3.ZERO  # Declare random_pos here
	
	while !valid_position and attempts < max_attempts:
		random_pos = Vector3(
			randf_range(bordermin, bordermax),
			randf_range(bordermin, bordermax), 
			randf_range(bordermin, bordermax)
		)
		
		valid_position = true
		
		for node in get_children():
			if node is CharacterBody3D:  # Check for other enemies instead of planets
				var distance = random_pos.distance_to(node.position)
				if distance < maxGap:
					valid_position = false
					break
		
		if valid_position:
			spawned_scene_copy.position = random_pos
		
		attempts += 1
	
	if valid_position:
		enemy_count += 1
		var node_name = "enemy_" + str(enemy_count)
			
		# Set name for the root node
		spawned_scene_copy.name = node_name
		spawned_scene_copy.add_to_group("planets")  # If they need to be in this group
		spawned_scene_copy.add_to_group("enemies")
			
		# Initialize the enemy's timers
		var idle_timer = spawned_scene_copy.get_node("IdleTimer")
		var alert_timer = spawned_scene_copy.get_node("AlertTimer")
		
		if idle_timer:
			idle_timer.start(randf_range(2, 4))  # Give each enemy a random start time
			
		add_child(spawned_scene_copy)
		print("Spawned enemy: ", node_name, " at position ", random_pos)
		return true
	else:
		print("Could not find valid position for ", enemy_type)
		return false
		
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Spawn a specific number of enemies
	var num_enemies = 400
	
	for i in range(num_enemies):
		spawn_enemy("enemy")
