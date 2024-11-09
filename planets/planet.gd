extends StaticBody


func _on_Area_body_entered(body):
	if body.name == "player":
		body.set_planet_name(name)


func _on_Area_body_exited(body):
	if body.name == "player":
		body.set_planet_name("space")
