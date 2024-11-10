extends StaticBody3D
func _ready():
	add_to_group("planets")
	
func _on_Area_body_entered(body):
	if body.name == "Player":
		print("player")
		body.set_planet_name(name)


func _on_Area_body_exited(body):
	if body.name == "Player":
		body.set_planet_name("space")
